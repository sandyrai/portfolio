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

1. **DNS**: add an `A` record `sandeep` → the VPS IP (same IP as `resume.ojasyukti.tech`).
2. **On the VPS**:
   ```bash
   sudo git clone https://github.com/sandyrai/portfolio.git /var/www/portfolio
   sudo sh -c 'cat /var/www/portfolio/deploy/Caddyfile.snippet >> /etc/caddy/Caddyfile'
   sudo caddy validate --config /etc/caddy/Caddyfile && sudo systemctl reload caddy
   ```
   Caddy gets the HTTPS certificate automatically.
3. **Google Search Console**: add `https://sandeep.ojasyukti.tech/`, verify it, and submit
   `sitemap.xml` so Google indexes the page quickly.

## Updating

Edit, commit and push, then on the VPS:

```bash
cd /var/www/portfolio && sudo git pull
```

When the resume changes, replace `assets/Sandeep_Kumar_Resume.pdf`, update the matching text in
`index.html`, and bump `<lastmod>` in `sitemap.xml` and `dateModified` in the JSON-LD.
