// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

import defaultTheme from 'tailwindcss/defaultTheme.js'
import colors from 'tailwindcss/colors.js'
import plugin from 'tailwindcss/plugin.js'
import fs from 'fs'
import path from 'path'
import tailwindcssTypography from '@tailwindcss/typography'
import tailwindcssForms from '@tailwindcss/forms'
import tailwindcssAspectRatio from '@tailwindcss/aspect-ratio'

export default {
  content: ['../../lib/user_web/**/*.*ex', './{lib,vendor}/**/*.js'],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter Variable', ...defaultTheme.fontFamily.sans],
        mono: ['JetBrains Mono Variable', ...defaultTheme.fontFamily.mono],
      },
      colors: {
        base: colors.slate,
        brand: colors.violet,
        blue: colors.sky,
        green: colors.emerald,
        yellow: colors.yellow,
        red: colors.red,
      },
    },
  },
  plugins: [
    tailwindcssTypography({ target: 'legacy' }),
    tailwindcssForms,
    tailwindcssAspectRatio,

    // Add variants for styling a <progress> element.
    //
    // An example:
    //
    //     <progress
    //       max="100"
    //       value="23"
    //       class={[
    //         "block w-full h-2",
    //         "progress-root:h-2 progress-root:rounded progress-root:bg-base-200",
    //         "progress-fill:h-2 progress-fill:rounded progress-fill:bg-brand-500"
    //       ]}
    //     ></progress>
    //
    plugin(({ addVariant }) => {
      addVariant('progress-root', ['&::-webkit-progress-bar', '&'])
      addVariant('progress-fill', ['&::-webkit-progress-value', '&::-moz-progress-bar'])
    }),

    // Add variants for styling elements which are applying LiveView classes.
    //
    // An example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) => {
      addVariant('phx-loading', ['.phx-loading&', '.phx-loading &'])
      addVariant('phx-connected', ['.phx-connected&', '.phx-connected &'])
      addVariant('phx-error', ['.phx-error&', '.phx-error &'])
      addVariant('phx-click-loading', ['.phx-click-loading&', '.phx-click-loading &'])
      addVariant('phx-submit-loading', ['.phx-submit-loading&', '.phx-submit-loading &'])
      addVariant('phx-change-loading', ['.phx-change-loading&', '.phx-change-loading &'])
    }),

    // Add hero-* components for supporting `BaseComponents.icon/1`.
    //
    // See `BaseComponents.icon/1` for more information.
    //
    plugin(function ({ matchComponents, theme }) {
      const iconsDir = path.join(__dirname, './node_modules/heroicons')
      const values = {}
      const icons = [
        ['', '/24/outline'],
        ['-outline', '/24/outline'],
        ['-solid', '/24/solid'],
        ['-mini', '/20/solid'],
        ['-micro', '/16/solid'],
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach((file) => {
          let name = path.basename(file, '.svg') + suffix
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) }
        })
      })
      matchComponents(
        {
          hero: ({ name, fullPath }) => {
            const content = fs
              .readFileSync(fullPath)
              .toString()
              .replace(/\r?\n|\r/g, '')

            let size = theme('spacing.6')
            if (name.endsWith('-mini')) {
              size = theme('spacing.5')
            } else if (name.endsWith('-micro')) {
              size = theme('spacing.4')
            }

            return {
              [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
              '-webkit-mask': `var(--hero-${name})`,
              mask: `var(--hero-${name})`,
              'mask-repeat': 'no-repeat',
              'background-color': 'currentColor',
              'vertical-align': 'middle',
              display: 'inline-block',
              width: size,
              height: size,
            }
          },
        },
        { values }
      )
    }),
  ],
}
