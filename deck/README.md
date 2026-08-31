# Deck

Generated file:

- `github-copilot-for-data-professionals.pptx`

Source:

- `scripts\build_deck.js`
- `scripts\download_product_icons.ps1`
- `scripts\generate_deck_assets.ps1`
- `scripts\apply_microsoft_template.ps1`
- `scripts\normalize_deck_layout.ps1`

Regenerate:

```powershell
.\scripts\download_product_icons.ps1
.\scripts\generate_deck_assets.ps1
npm install
npm run build:deck
.\scripts\apply_microsoft_template.ps1
.\scripts\normalize_deck_layout.ps1
```

The deck uses:

- Official product icons in `deck\assets\icons` (GitHub, GitHub Copilot, Microsoft Fabric)
- Generated PNG artwork in `deck\assets` for PowerPoint compatibility
- A Microsoft-branded template applied post-build
