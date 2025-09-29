import { Head } from '@inertiajs/react'
import logo from "../../images/logo.svg"

export default function Home({}) {
  return (
    <>
      <Head title="MyApp.Web" />
      <div className="page-container">
        <main className="main-container">
          <img className="logo" src={logo}/>
          <div>
            <h1 className="sr-only">Combo</h1>
            <p className="description">
              A web framework, that combines the good parts of modern web development.
            </p>
          </div>
        </main>
      </div>
    </>
  );
}
