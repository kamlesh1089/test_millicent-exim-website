# Millicent Exim responsive homepage rebuild

## Decision

Replace the image-backed desktop implementation with one real, semantic, responsive HTML homepage. `assets/reference.png` is the binding visual reference at the approved desktop width of 941 px. It is a calibration artifact only and must not be used as the desktop page rendering.

## Binding visual contract

- Preserve the approved desktop composition exactly: the warm ivory background, gold accents, black editorial serif type, product imagery, navy packaging band, section order, copy, labels, decorative lines, and spacing.
- Preserve the existing six homepage stories: hero, product range, packaging, sourcing and quality, global markets, and final CTA. Keep the current footer.
- Retain the corrected India placement and routes in `assets/market-map-corrected.png`. No alternative map may be used.
- Do not add, delete, rename, or rewrite visible copy, statistics, products, navigation items, or calls to action.
- Do not introduce rounded-card templates, gradients, animations, visual effects, badges, new colors, or visual elements absent from the approved reference.
- The primary desktop comparison viewport is 941 x 1672. Minor browser font rasterisation differences are acceptable; changed layout, copy, proportions, or visual treatment is not.

## Real-page structure

The existing `index.html` becomes a semantic document with a DOM-rendered header, main content, and footer:

1. Header with the logo, Home, Categories, Packaging, Sourcing, Markets, About, Contact, and Get In Touch links.
2. Hero with its existing copy, primary actions, trust points, and commodity image composition.
3. Product portfolio with five real product cards: Rice, Wheat, Pulses, Lentils, and Specialty Staples.
4. Packaging section using the existing navy/gold pack images and format labels.
5. Sourcing and quality section with the grain-hand image and four quality pillars.
6. Global markets section using the corrected India map and the existing statistics.
7. Final agricultural CTA and the existing footer navigation/social presentation.

Every visible navigation item and call to action is a real link or button. Header and footer links scroll to their matching section; the conversation action retains its existing `mailto:sales@millicentexim.com` destination. No transparent click regions or static screenshot overlays remain.

## Responsive behavior

- Desktop (761 px and above): retain the approved wide composition, real header navigation, multi-column cards, horizontal packaging lineup, sourcing split, and map layout.
- Mobile (760 px and below): use the existing visual system but reflow into a single readable column. The header becomes a genuine keyboard-accessible hamburger menu. Product cards stack, packaging remains horizontally scrollable, and buttons retain touch-safe height.
- Tablet: interpolate fluidly between these layouts without horizontal overflow or a separate visual design.
- Keyboard focus is visible; reduced-motion preferences disable smooth scroll.

## Asset and implementation boundaries

- Reuse only the existing assets under `assets/` for visible imagery and logos.
- Keep this dependency-free static site: no framework, build step, analytics, form provider, or external script is introduced.
- CSS and small interaction scripts may be separated from `index.html` only when that improves clarity without changing the rendered result.

## Verification requirements

1. An automated static-page check proves the page has real section anchors, no desktop `reference.png` rendering element, all navigation targets resolve, and the corrected map is used.
2. The test must be written and observed failing before the implementation change, then pass after it.
3. Browser checks at the approved desktop viewport and a phone viewport confirm the real header/menu links navigate to their sections and the page has no horizontal overflow.
4. A desktop screenshot is visually compared against `assets/reference.png`; any meaningful deviation is corrected before deployment.
5. The production Vercel alias returns the rebuilt homepage with a 200 response.
