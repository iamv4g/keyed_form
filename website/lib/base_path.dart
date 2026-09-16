/// The subpath this site is served under on GitHub Pages
/// (`https://iamv4g.github.io/keyed_form/`).
///
/// `jaspr build` pre-renders every route through an internal server that
/// always serves from `/`, so anchor hrefs baked into the static HTML at
/// build time need this prefix hardcoded — there's no CLI flag for it, and
/// jaspr_router's `Link` only resolves the real `<base>` path client-side,
/// after hydration.
const siteBasePath = '/keyed_form';
