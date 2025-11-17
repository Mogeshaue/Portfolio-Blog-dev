# Automated Blog Sync Setup

This setup automatically syncs blog posts from the `Blogs-dev` repository to your portfolio whenever you publish a new blog.

## How It Works

1. You push a new blog to `Blogs-dev` repository
2. GitHub Actions detects the change
3. Automatically triggers portfolio sync
4. Portfolio repository updates with new blogs
5. Vercel automatically deploys the updated site ✨

## Setup Instructions

### Step 1: Create a Personal Access Token (PAT)

1. Go to GitHub: https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Name it: `Blog Sync Token`
4. Set expiration: **No expiration** (or choose a long period)
5. Select scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `workflow` (Update GitHub Action workflows)
6. Click **"Generate token"**
7. **COPY THE TOKEN** (you won't see it again!)

### Step 2: Add Token to Blogs-dev Repository

1. Go to your Blogs-dev repository: https://github.com/Mogeshaue/Blogs-dev
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. Name: `PAT_TOKEN`
5. Value: Paste the token you copied in Step 1
6. Click **"Add secret"**

### Step 3: Add Workflow to Blogs-dev Repository

1. In your `Blogs-dev` repository, create this file:
   ```
   .github/workflows/trigger-portfolio-sync.yml
   ```

2. Copy the contents from `BLOGS_DEV_WORKFLOW.yml` (in this repository)

3. Commit and push to Blogs-dev

### Step 4: Push This Workflow to Portfolio

The workflow is already created in `.github/workflows/sync-blogs.yml`

Just commit and push this repository:
```bash
git add .
git commit -m "feat: add automated blog sync workflow"
git push
```

### Step 5: Configure Vercel (Already Done!)

Vercel automatically deploys when the main/dev branch is updated.

## Usage

### Publishing a New Blog

1. Create your blog in `Blogs-dev/src/content/blog/your-blog-name/index.md`
2. Commit and push to Blogs-dev
3. GitHub Actions will automatically:
   - Sync the blog to portfolio
   - Trigger Vercel deployment
   - Your blog appears on your live site! 🎉

### Blog Format

```markdown
---
title: "Your Blog Title"
date: "2025-11-17"
draft: false
summary: "Brief description of your blog post"
tags: ["tag1", "tag2", "tag3"]
---

Your blog content here...
```

## Manual Sync

If you need to manually trigger a sync:

1. Go to: https://github.com/Mogeshaue/portfolio-blog/actions
2. Select **"Sync Blogs from Blogs-dev"**
3. Click **"Run workflow"**
4. Select branch and click **"Run workflow"**

## Testing

To test the setup:

1. Create a test blog in Blogs-dev
2. Push to Blogs-dev repository
3. Check Actions tab to see the workflow running
4. Wait for Vercel deployment to complete
5. Visit your site to see the new blog!

## Troubleshooting

### Workflow not triggering?
- Check if PAT_TOKEN is added to Blogs-dev secrets
- Verify the workflow file is in `.github/workflows/` in Blogs-dev
- Check if changes are in `src/content/blog/` path

### Blogs not syncing?
- Check Actions tab for error messages
- Ensure blog format matches the schema in `src/content/config.ts`
- Verify the blog is not in the `drafts` folder

### Vercel not deploying?
- Check Vercel dashboard for build errors
- Ensure Root Directory is set to `Astro-template` in Vercel settings

## Architecture

```
Blogs-dev Repository
       ↓ (push blog)
GitHub Actions (trigger-portfolio-sync.yml)
       ↓ (repository_dispatch)
Portfolio Repository
       ↓ (sync-blogs.yml runs)
Portfolio Updated
       ↓ (auto-deploy)
Vercel Deployment
       ↓
Live Website 🚀
```

## Files Created

- `.github/workflows/sync-blogs.yml` - Main sync workflow (in portfolio)
- `BLOGS_DEV_WORKFLOW.yml` - Trigger workflow (copy to Blogs-dev)
- `sync-blogs.ps1` - Local PowerShell sync script (optional)
- `BLOG_SYNC_SETUP.md` - This documentation

---

**🎉 Once set up, you'll never need to manually sync blogs again!**
