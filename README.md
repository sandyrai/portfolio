# sandeep.ojasyukti.tech

Personal portfolio of **Sandeep Kumar**, Senior Software Engineer (Java, Spring Boot, Kafka, AWS).

A single static page: hand-written HTML and CSS, no framework and no build step.
Served by Caddy on the OjasYukti VPS.

## Files

| Path | What it is |
| --- | --- |
| `index.html` | The whole site: content, styles, SEO tags and JSON-LD structured data |
| `assets/` | Portrait (WebP + JPG, 480/800 px), social share image, touch icon, resume PDF |
| `favicon.svg`, `site.webmanifest` | Icons |
| `robots.txt`, `sitemap.xml` | Search engine crawling |
| `404.html` | Not-found page |
| `deploy/Caddyfile.snippet` | Caddy site block for the VPS |

## Preview locally

```bash
python -m http.server 8080
```

Then open http://localhost:8080.

## First deploy (one time)

`ojdeploy` has no sudo and `/var/www` is owned by root, so two steps need you:

1. **DNS (Hostinger)**: add an `A` record `sandeep` → `93.127.185.236` (same IP as `resume`).
2. **Stage** the site and the Caddy block on the server (from this PC):
   ```bash
   bash deploy/deploy.sh --stage
   ```
3. **On the VPS, as your sudo user**:
   ```bash
   sudo install -d -o ojdeploy -g ojdeploy -m 755 /var/www/portfolio
   sudo cp -a /home/ojdeploy/portfolio-release/. /var/www/portfolio/
   sudo chown -R ojdeploy:ojdeploy /var/www/portfolio
   sudo cp /etc/caddy/Caddyfile /etc/caddy/Caddyfile.backup-$(date +%Y%m%d-%H%M%S)
   sudo sh -c 'cat /home/ojdeploy/portfolio.caddy >> /etc/caddy/Caddyfile'
   sudo caddy validate --config /etc/caddy/Caddyfile && sudo systemctl reload caddy
   ```
   Caddy gets the HTTPS certificate once DNS points at the server.
4. **Google Search Console**: add `https://sandeep.ojasyukti.tech/`, verify it, and submit
   `sitemap.xml`. Check the LinkedIn card at linkedin.com/post-inspector.

## Updating

Edit, commit and push, then from this PC:

```bash
bash deploy/deploy.sh
```

It ships only the public files of the last commit, keeps the previous version in
`~/portfolio-prev` on the server, and restores it if the site stops responding.

When the resume changes, replace `assets/Sandeep_Kumar_Resume.pdf`, update the matching text in
`index.html`, and bump `<lastmod>` in `sitemap.xml` and `dateModified` in the JSON-LD.
When the photo changes, bump `?v=2` on the `og:image` / `twitter:image` URLs so LinkedIn and
WhatsApp fetch the new card.
