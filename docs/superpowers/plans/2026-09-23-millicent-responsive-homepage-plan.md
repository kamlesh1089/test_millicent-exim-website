# Millicent Exim Responsive Homepage Rebuild Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the approved Millicent Exim homepage as a genuine semantic HTML/CSS/JS responsive website that preserves the reference design at the 941 px desktop viewport and works on desktop, tablet, and mobile.

**Architecture:** Keep the site dependency-free and static. `index.html` owns the semantic page structure and copy, `assets/styles.css` owns the calibrated visual system and responsive layout, and `assets/main.js` owns only the mobile menu and small navigation behavior. Existing images remain the source assets; `assets/reference.png` is used only by visual comparison, never rendered as the desktop page.

**Tech Stack:** HTML5, CSS3, vanilla JavaScript, PowerShell static contract test, browser verification with the available Chrome/Computer Use workflow.

**Spec:** `docs/superpowers/specs/2026-09-23-millicent-responsive-homepage-design.md`

## Global Constraints

- Preserve the approved desktop composition exactly: warm ivory background, gold accents, black editorial serif type, product imagery, navy packaging band, section order, copy, labels, decorative lines, and spacing.
- Retain the existing six homepage stories: hero, product range, packaging, sourcing and quality, global markets, and final CTA. Keep the current footer.
- Retain `assets/market-map-corrected.png`; no alternative map is allowed.
- Do not add, delete, rename, or rewrite visible copy, statistics, products, navigation items, or calls to action.
- Do not use `assets/reference.png` as a rendered desktop element, transparent click regions, or static screenshot overlays.
- Keep the site dependency-free and static; reuse only the existing assets under `assets/`.
- Desktop target viewport is 941 x 1672; mobile is 760 px and below; tablet must interpolate without horizontal overflow.

## Review Focus

- Desktop fidelity at 941 px: the real DOM must preserve the approved section order, proportions, type scale, and palette without rendering the reference screenshot.
- Navigation integrity: every header/footer item must resolve to a real section target, including direct deep links and the mailto CTA.
- Mobile interaction: the hamburger must expose a keyboard-accessible menu, close after selection, and never trap focus or cause overflow.
- Asset correctness: every visible image must resolve from the existing asset set, use the corrected India map, and have meaningful alt text.
- Responsive boundaries: the layout must not overflow horizontally between phone, tablet, and desktop widths.

---

### Task 1: Establish the failing semantic homepage contract

**Files:**
- Create: `tests/validate-homepage.ps1`
- Read: `index.html`, `docs/superpowers/specs/2026-09-23-millicent-responsive-homepage-design.md`

**Interfaces:**
- Produces: a repeatable exit-code check for the required semantic structure and asset rules.

- [ ] **Step 1: Write the failing contract test**

Create `tests/validate-homepage.ps1` with this executable check:

```powershell
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$html = Get-Content -Raw (Join-Path $root 'index.html')

function Assert-Contains([string]$pattern, [string]$message) {
  if ($html -notmatch [regex]::Escape($pattern)) { throw $message }
}

function Assert-NotContains([string]$pattern, [string]$message) {
  if ($html -match [regex]::Escape($pattern)) { throw $message }
}

Assert-Contains '<header id="site-header"' 'Missing semantic site header.'
Assert-Contains '<main id="main-content"' 'Missing main content landmark.'
Assert-Contains '<footer id="site-footer"' 'Missing semantic site footer.'
Assert-NotContains 'src="assets/reference.png"' 'Desktop must not render the reference screenshot.'
Assert-NotContains 'class="hotspot' 'Transparent screenshot click zones must be removed.'
Assert-Contains 'assets/market-map-corrected.png' 'Corrected India map asset is not used.'
Assert-Contains 'id="mobile-menu"' 'Missing mobile menu control.'
Assert-Contains 'aria-expanded="false"' 'Mobile menu must expose its initial state.'

$requiredIds = @('home','categories','packaging','sourcing','markets','about','contact')
foreach ($id in $requiredIds) {
  Assert-Contains "id=\"$id\"" "Missing section target #$id."
  Assert-Contains "href=\"#$id\"" "Missing navigation link to #$id."
}

$imageSources = [regex]::Matches($html, 'src="([^"]+)"') | ForEach-Object { $_.Groups[1].Value }
foreach ($src in $imageSources) {
  if ($src -notmatch '^assets/') { throw "Image source is outside the approved assets directory: $src" }
}

Write-Output 'Homepage contract: PASS'
```

- [ ] **Step 2: Run the test to verify it fails for the old image-backed page**

Run: `pwsh -NoProfile -File tests/validate-homepage.ps1`

Expected: FAIL with `Missing semantic site header.` or `Desktop must not render the reference screenshot.`. This confirms the test protects the requested rebuild rather than merely checking the existing implementation.

- [ ] **Step 3: Commit the failing contract test**

```powershell
git add tests/validate-homepage.ps1
git commit -m "test: define semantic Millicent homepage contract"
```

### Task 2: Replace the screenshot shell with semantic page markup

**Files:**
- Modify: `index.html`
- Test: `tests/validate-homepage.ps1`

**Interfaces:**
- Consumes: Existing copy, image assets, and the approved reference composition.
- Produces: Semantic landmarks and section IDs `home`, `categories`, `packaging`, `sourcing`, `markets`, and `contact` consumed by CSS, navigation, and tests.

- [ ] **Step 1: Replace the body with real landmarks and section content**

Use this structure as the DOM contract; retain the exact approved copy and existing asset filenames inside each section:

```html
<body>
  <header id="site-header" class="site-header">
    <a class="brand" href="#home" aria-label="Millicent Exim home"><img src="assets/logo.png" alt="Millicent Exim"></a>
    <nav class="desktop-nav" aria-label="Primary navigation">
      <a href="#home">Home</a><a href="#categories">Categories</a><a href="#packaging">Packaging</a>
      <a href="#sourcing">Sourcing</a><a href="#markets">Markets</a><a href="#about">About</a><a href="#contact">Contact</a>
    </nav>
    <a class="header-cta" href="#contact">Get In Touch →</a>
    <button id="mobile-menu" class="menu-toggle" type="button" aria-expanded="false" aria-controls="mobile-nav">Menu</button>
    <nav id="mobile-nav" class="mobile-nav" aria-label="Mobile navigation" hidden>
      <a href="#home">Home</a><a href="#categories">Categories</a><a href="#packaging">Packaging</a>
      <a href="#sourcing">Sourcing</a><a href="#markets">Markets</a><a href="#about">About</a><a href="#contact">Contact</a>
    </nav>
  </header>
  <main id="main-content">
    <section id="home" class="hero">
      <p class="eyebrow">Premium Indian Agro Commodities<br>For a Brighter Tomorrow</p>
      <h1>India’s Agro Commodities, Supplied with Trust.</h1>
      <p>Millicent Exim supplies rice, wheat, pulses, lentils, and staple agro commodities to global buyers with a commitment to quality, reliability, and long-term partnerships.</p>
      <a href="#categories">View Categories →</a><a href="#contact">Partner With Us</a>
      <ul><li>Multi-Commodity Export</li><li>Flexible Supply Formats</li><li>Long-Term Trade Relationships</li></ul>
      <img src="assets/hero.jpg" alt="Rice, wheat, pulses and staple agro commodities">
    </section>
    <section id="categories" class="product-range">
      <p class="eyebrow">Our Product Range</p><h2>Across Grains, Pulses, and Staple Commodities.</h2>
      <p>From everyday essentials to specialty grains, Millicent Exim offers a diverse range of high-quality agro commodities to meet global market needs.</p>
      <article><img src="assets/rice.jpg" alt="Rice"><h3>Rice</h3><p>Basmati, Non-Basmati and other varieties.</p></article>
      <article><img src="assets/wheat.jpg" alt="Wheat"><h3>Wheat</h3><p>Premium quality milling wheat.</p></article>
      <article><img src="assets/pulses.jpg" alt="Pulses"><h3>Pulses</h3><p>Chickpeas, peas, beans and more.</p></article>
      <article><img src="assets/lentils.jpg" alt="Lentils"><h3>Lentils</h3><p>Red, yellow, green and other lentil varieties.</p></article>
      <article><img src="assets/specialty.jpg" alt="Specialty staples"><h3>Specialty Staples</h3><p>Millets, barley, maize and more.</p></article>
    </section>
    <section id="packaging" class="packaging">
      <p class="eyebrow">Our Packaging</p><h2>Formats Designed for Retail, Trade, and Bulk.</h2>
      <p>Flexible and reliable packaging solutions for every buyer segment, from retail packs to bulk shipments.</p><a href="#contact">Explore Packaging Options →</a>
      <article><img src="assets/pack-rice.png" alt="Retail pack"><h3>Retail Packs</h3><p>1 kg</p></article>
      <article><img src="assets/pack-wheat.png" alt="Family pack"><h3>Family Packs</h3><p>5 kg</p></article>
      <article><img src="assets/pack-chana.png" alt="Trade pack"><h3>Trade Packs</h3><p>10 kg</p></article>
      <article><img src="assets/pack-lentils.png" alt="Export sack"><h3>Export Sacks</h3><p>25–50 kg</p></article>
      <article><img src="assets/pack-private.png" alt="Private label"><h3>Bulk / Private Label</h3><p>Customized Solutions</p></article>
    </section>
    <section id="sourcing" class="sourcing">
      <img src="assets/sourcing.jpg" alt="Hands holding grain in a farm"><p class="eyebrow">Our Sourcing &amp; Quality</p><h2>Origin Transparency. Quality You Can Verify.</h2>
      <p>We work closely with Indian farmers and trusted suppliers to ensure authentic origins, consistent quality, and reliable supply.</p>
      <ul><li><strong>Direct Procurement</strong><span>Sourced from trusted farming regions.</span></li><li><strong>Multi-Stage Checks</strong><span>Quality control at every stage.</span></li><li><strong>Export Documentation</strong><span>Compliant and hassle-free.</span></li><li><strong>Consistent Fulfilment</strong><span>Reliable supply for long-term growth.</span></li></ul>
    </section>
    <section id="markets" class="markets">
      <p class="eyebrow">Our Markets</p><h2>Connecting Indian Supply to Global Demand.</h2>
      <p>We serve importers, distributors, and institutional buyers across key international markets with reliable supply and consistent quality.</p>
      <ul><li><strong>50+</strong><span>Countries</span></li><li><strong>100+</strong><span>Buyers</span></li><li><strong>Long-Term</strong><span>Partnerships</span></li></ul>
      <img src="assets/market-map-corrected.png" alt="Corrected global markets map showing India in its proper location">
    </section>
    <section id="contact" class="final-cta">
      <p class="eyebrow">Partner for a Brighter Tomorrow</p><h2>Let’s Build Stronger Supply Chains Together.</h2>
      <p>Share your sourcing needs, packaging preference, and buyer requirements with our team. We’re here to create long-term value, together.</p>
      <a href="mailto:sales@millicentexim.com">Start a Conversation →</a><p>Importers | Distributors | Private Label Buyers</p>
    </section>
  </main>
  <footer id="site-footer" class="site-footer">
    <div id="about" class="footer-about">
      <img src="assets/logo.png" alt="Millicent Exim">
      <nav aria-label="Footer navigation"><a href="#home">Home</a><a href="#categories">Categories</a><a href="#packaging">Packaging</a><a href="#sourcing">Sourcing</a><a href="#markets">Markets</a><a href="#about">About</a><a href="#contact">Contact</a></nav>
      <p>© 2026 Millicent Exim. All rights reserved.</p><p>Indian Agro Commodities. Trusted Worldwide.</p>
    </div>
  </footer>
  <script src="assets/main.js" defer></script>
</body>
```

Keep the copy and asset-backed elements exactly as shown above; do not invent text or use a screenshot as a substitute. Give every content image a descriptive `alt` value and every decorative rule/mark `aria-hidden="true"`.

- [ ] **Step 2: Run the contract test**

Run: `pwsh -NoProfile -File tests/validate-homepage.ps1`

Expected: PASS for landmarks, section targets, corrected map, and removal of `reference.png`/`.hotspot` markup. It may still report CSS/interaction work as incomplete in the browser; that is handled by later tasks.

- [ ] **Step 3: Commit the semantic markup**

```powershell
git add index.html
git commit -m "feat: replace Millicent screenshot shell with semantic markup"
```

### Task 3: Calibrate the desktop visual system

**Files:**
- Create: `assets/styles.css`
- Modify: `index.html` to load `assets/styles.css`
- Test: `tests/validate-homepage.ps1`

**Interfaces:**
- Consumes: The semantic IDs/classes from Task 2 and the existing asset files.
- Produces: The 941 px desktop layout and fluid tablet layout used by browser verification.

- [ ] **Step 1: Add the desktop token and layout rules**

Start `assets/styles.css` with these fixed tokens and calibration rules, then implement the section-specific grids against the reference screenshot:

```css
:root {
  --ivory: #fbf7ee;
  --ivory-deep: #f7f0e4;
  --ink: #11100e;
  --muted: #50483f;
  --brown: #704820;
  --gold: #b57d28;
  --gold-soft: #d4ae68;
  --navy: #041c30;
  --line: #d9cbbb;
  --content: min(100% - 72px, 1360px);
}

html { scroll-behavior: smooth; background: var(--ivory); }
body { margin: 0; color: var(--ink); background: var(--ivory); font-family: Georgia, "Times New Roman", serif; }
img { display: block; max-width: 100%; }
.site-header { display: grid; grid-template-columns: 190px 1fr auto; align-items: center; gap: 28px; width: var(--content); margin: 0 auto; min-height: 76px; }
.desktop-nav { display: flex; justify-content: center; gap: clamp(18px, 2.6vw, 42px); }
.desktop-nav a, .site-footer a { color: var(--ink); text-decoration: none; }
.hero, .product-range, .sourcing, .markets, .final-cta, .site-footer { background: var(--ivory); }
.packaging { color: #fff; background: var(--navy); }
.section-inner { width: var(--content); margin: 0 auto; }
```

Match the reference by calibrating the hero as a two-column composition, the product range as five equal cards, packaging as a navy split with five pack items, sourcing as image/text split, markets as text/map split, and CTA as a full-width field image. Use the existing Playfair/Georgia editorial hierarchy and Manrope/system utility sizing already specified by the approved page; do not add a new visual language.

- [ ] **Step 2: Verify desktop structure without changing behavior**

Run: `pwsh -NoProfile -File tests/validate-homepage.ps1`

Expected: `Homepage contract: PASS`. Then load the page at 941 px wide and capture a screenshot. Compare section boundaries, header placement, hero crop, card widths, navy band height, map position, CTA, and footer against `assets/reference.png`; adjust only CSS geometry/tokens needed to match.

- [ ] **Step 3: Commit the calibrated desktop pass**

```powershell
git add index.html assets/styles.css
git commit -m "feat: calibrate Millicent desktop layout in real HTML"
```

### Task 4: Add responsive layout and real mobile navigation

**Files:**
- Create: `assets/main.js`
- Modify: `assets/styles.css`, `index.html`
- Test: `tests/validate-homepage.ps1`

**Interfaces:**
- Consumes: `#mobile-menu`, `#mobile-nav`, section IDs, and the semantic markup from Tasks 2–3.
- Produces: A closed-by-default mobile menu with `aria-expanded` state and real navigation links.

- [ ] **Step 1: Add the responsive rules**

At `max-width: 760px`, hide `.desktop-nav` and `.header-cta`, show `.menu-toggle`, convert the header to a compact two-column layout, stack content sections, keep product cards one column, preserve horizontal packaging scrolling, and make every CTA at least 48 px tall. Add `overflow-x: clip` to `body` only after confirming it does not hide intended horizontal packaging scrolling.

- [ ] **Step 2: Add the minimal menu behavior**

Create `assets/main.js` with this behavior:

```js
const menuButton = document.querySelector('#mobile-menu');
const mobileNav = document.querySelector('#mobile-nav');

function setMenu(open) {
  menuButton.setAttribute('aria-expanded', String(open));
  mobileNav.hidden = !open;
  document.body.classList.toggle('menu-open', open);
}

if (menuButton && mobileNav) {
  menuButton.addEventListener('click', () => setMenu(menuButton.getAttribute('aria-expanded') !== 'true'));
  mobileNav.querySelectorAll('a').forEach((link) => link.addEventListener('click', () => setMenu(false)));
  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') setMenu(false);
  });
}
```

- [ ] **Step 3: Extend the contract test for mobile behavior**

Add these assertions to `tests/validate-homepage.ps1`:

```powershell
Assert-Contains 'assets/main.js' 'Mobile behavior script is not loaded.'
Assert-Contains 'id="mobile-nav"' 'Mobile navigation landmark is missing.'
Assert-Contains 'menuButton.addEventListener' 'Mobile menu click behavior is missing.'
Assert-Contains 'event.key === ''Escape''' 'Mobile menu Escape behavior is missing.'
```

- [ ] **Step 4: Run the checks**

Run: `pwsh -NoProfile -File tests/validate-homepage.ps1`

Expected: `Homepage contract: PASS`. In Chrome, verify at a phone-sized viewport that the menu opens, exposes the links, closes on link selection and Escape, and the page has no horizontal overflow.

- [ ] **Step 5: Commit the responsive pass**

```powershell
git add index.html assets/styles.css assets/main.js tests/validate-homepage.ps1
git commit -m "feat: add responsive layout and accessible mobile navigation"
```

### Task 5: Full verification and handoff

**Files:**
- Modify: none unless a verification failure identifies a CSS/HTML correction.
- Test: `tests/validate-homepage.ps1`, browser checks, visual screenshot comparison.

**Interfaces:**
- Consumes: The complete static site from Tasks 1–4.
- Produces: A clean, verified commit ready for the connected Vercel project.

- [ ] **Step 1: Run the static contract and whitespace checks**

Run:

```powershell
pwsh -NoProfile -File tests/validate-homepage.ps1
git diff --check
git status --short
```

Expected: the contract prints `Homepage contract: PASS`, `git diff --check` is silent, and the worktree is clean after the final commit.

- [ ] **Step 2: Verify desktop interaction and visual fidelity**

At 941 px wide, click Home, Categories, Packaging, Sourcing, Markets, About, Contact, Get In Touch, and the three content actions. Confirm each hash target is reached and the mailto CTA retains its destination. Capture a full-page screenshot and compare it with `assets/reference.png`; reject any changed copy, missing section, wrong image, wrong map, or materially different geometry.

- [ ] **Step 3: Verify mobile interaction and boundaries**

At 390 px and 768 px widths, open and close the menu with mouse/keyboard, activate every menu link, confirm focus remains visible, confirm the packaging row is the only intended horizontal scroller, and confirm there is no page-level horizontal overflow.

- [ ] **Step 4: Commit any final verification-only corrections**

```powershell
git add index.html assets/styles.css assets/main.js tests/validate-homepage.ps1
git commit -m "fix: complete Millicent responsive homepage verification"
```

- [ ] **Step 5: Publish only after local verification passes**

Push the verified `main` commit to `kamlesh1089/test_millicent-exim-website`, wait for the connected Vercel project to report `READY`, request the production alias, and load it with a 200 response. Confirm the deployed HTML title and corrected map asset before reporting the live URL.
