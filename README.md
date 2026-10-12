# Supplements Unlocked

A responsive, dark-first supplement reference site, with a public read-only library and private admin editing. Built with HTML, CSS, vanilla JavaScript, and Supabase. Starts with **zero supplements and zero categories**.

## Included
- `index.html` — main page
- `styles.css` — responsive styling / light and dark themes
- `app.js` — public cards, dropdown category filter, search, detail pages, admin login, content editing, category management, image upload, JSON export
- `config.js` — cloud project settings (fill these in)
- `schema.sql` — PostgreSQL schema, Row Level Security policies and Storage bucket

## Setup (about 20–40 minutes after files are ready)
1. Create a Supabase project at https://supabase.com/dashboard.
2. Open **SQL Editor**, paste the contents of `schema.sql`, and click **Run**. Do this once in a new project.
3. Under **Authentication > Users**, create your admin account with your own email and a strong password. Verify/confirm the account as appropriate. Under Auth settings, disable public account signup if you don't want anyone else registering.
4. Copy your user UUID from **Authentication > Users**. In SQL Editor run:
   ```sql
   insert into public.admins(user_id) values ('PASTE-YOUR-AUTH-USER-UUID-HERE');
   ```
   Do not put your email/password in SQL or in the website files.
5. In **Project Settings > API / Connect**, find your **Project URL** and **publishable key** (legacy anon key also works). Replace the placeholders in `config.js`. **Never use the service_role or secret key in browser code.**
6. Test locally using a static server (not `file://`): from the project folder run `python3 -m http.server 8080`, then open `http://localhost:8080`.
7. Sign in via **Admin Login**. Add categories in **Admin Panel**, then add your first supplement on the homepage.
8. Publish the folder to a static host such as Netlify or Vercel. The host must serve `index.html`, `app.js`, `styles.css`, `config.js` at the same directory level. The site uses hash-based navigation, so no rewrite rules are needed.

## Security notes
- Public users can read supplements/categories and images but cannot write. RLS and Storage policies enforce admin-only writes server-side.
- Only user UUIDs manually entered into `public.admins` have admin rights; never allow users to insert into this table.
- Keep Supabase Auth email confirmation / password recovery configured for your domain if needed.
- Uploaded image files are publicly readable by design. Avoid private or sensitive uploads.
- JSON export saves data records and image URLs, **not the image files**. Keep separate image backups when needed.
- If you replace an image, the old image may remain in storage; periodically clean up unused files from the Supabase dashboard.
- Avoid running `schema.sql` twice unchanged: the policies are intended for a new project and use CREATE POLICY statements.
- Supabase's free-tier limits and hosting terms may change; review current plans before production launch.

## Scientific content
The editor provides optional section suggestions (Overview, Mechanism of Action, Clinical Benefits, Dosage, Safety, Interactions, Clinical Pearls, References). You can remove, rename or add sections. No supplement content is pre-populated.

## Important
The source package is ready for cloud integration, but the cloud project is **not created or deployed** until you perform the setup steps in your own Supabase/hosting accounts.


## Scientific content template (v2)

New supplements automatically start with these 12 editable sections:

1. Overview & Identity
2. Forms & Bioavailability
3. Mechanism of Action
4. Clinical Uses & Evidence
5. Dosage & Administration
6. Deficiency & Assessment
7. Safety, Contraindications & Toxicity
8. Drug & Supplement Interactions
9. Special Populations
10. Monitoring & Follow-up
11. Clinical Pearls
12. Scientific References

Existing supplements keep their saved sections unchanged. Administrators can rename, remove, or add sections. The sections are stored in the existing `supplements.sections` JSON field, so no SQL migration is needed. To publish the change, replace `app.js` in the GitHub repository and let Vercel redeploy.
