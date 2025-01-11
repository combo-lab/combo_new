import { defineConfig } from "vite"

import mergeOptions from "merge-options"

import resolveConfig from "tailwindcss/resolveConfig"
import tailwindConfig from "./tailwind.config"

import pcImport from "postcss-import"
import pcAutoprefixer from "autoprefixer"
import pcTailwindcss from "tailwindcss"
import pcTailwindcssNesting from "tailwindcss/nesting"

const {
  theme: { colors: tailwindColors },
} = resolveConfig(tailwindConfig)

const target = "es2017"
const outDir = "../../priv/user_web/static/"
const assetsDir = "assets"

// watch STDIN and terminate Vite when Phoenix quits
function watchStdin() {
  process.stdin.on("close", () => {
    process.exit(0)
  })

  process.stdin.resume()
}

export default defineConfig(({ mode: mode }) => {
  const isProduction = mode === "production"
  const isDevelopment = mode === "development"

  if (isDevelopment) {
    watchStdin()
  }

  const defaultOptions = {
    appType: "custom",
    resolve: {
      extensions: [".js", ".css"],
    },

    // use relative path in asset references, such as JS-imported asset URLs,
    // CSS url() references.
    base: "./",

    // prevent clearing the terminal screen when logging certain messages
    clearScreen: false,

    build: {
      outDir: outDir,
      emptyOutDir: false,

      // Don't generate a manifest file, Phoenix has its own mechanism for
      // generating cache manifest files.
      manifest: false,

      // Specify the directory to nest generated assets under build.outDir
      assetsDir: assetsDir,

      // Disable inline assets
      assetsInlineLimit: 0,

      rollupOptions: {
        input: {
          app: "app.js",
        },
        output: {
          entryFileNames: `${assetsDir}/[name].js`,
          chunkFileNames: `${assetsDir}/[name].js`,
          assetFileNames: `${assetsDir}/[name][extname]`,
        },
      },
    },
  }

  const globalConstants = {
    define: {
      __TAILWIND_COLORS__: JSON.stringify(tailwindColors),
    },
  }

  const copyPublicOptions = {
    publicDir: "public",
    build: {
      copyPublicDir: true,
    },
  }

  const cssOptions = {
    css: {
      postcss: {
        plugins: [pcImport, pcTailwindcssNesting, pcTailwindcss, pcAutoprefixer],
      },
    },
  }

  const buildTargetOptions = {
    build: {
      target: target,
    },
  }

  const minifyOptions = isProduction
    ? {
        build: {
          sourcemap: false,
          minify: true,
        },
      }
    : {
        build: {
          sourcemap: true,
          minify: false,
        },
      }

  return mergeOptions(
    defaultOptions,
    globalConstants,
    cssOptions,
    copyPublicOptions,
    buildTargetOptions,
    minifyOptions,
  )
})
