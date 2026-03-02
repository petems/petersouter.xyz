---
name: add-unsplash-image-to-blog
description: "Search Unsplash for a photo and add it to a blog post as a cover/thumbnail image. Downloads the image, saves it following site conventions, updates frontmatter, and adds Unsplash attribution."
user_invocable: true
---

# Add Unsplash Image to Blog Post

Search Unsplash for a relevant photo, download it, and add it to a blog post as a cover image, thumbnail image, or in-body image — with proper attribution.

## Prerequisites

This skill uses the Unsplash API. The user must have an Unsplash Access Key available as the environment variable `UNSPLASH_ACCESS_KEY`. If the variable is not set, ask the user to provide one (get a key at https://unsplash.com/developers).

---

## Mandatory Execution Flow

### Step 0: Gather Requirements

Confirm the following with the user:

1. **Target post**: Which blog post should receive the image? (file path or slug)
2. **Search query**: What kind of image are they looking for? (e.g. "server rack", "mountains at sunset", "cooking pasta")
3. **Image usage**: How should the image be used?
   - `cover` — set as `coverImage` in frontmatter (default)
   - `thumbnail` — set as `thumbnailImage` in frontmatter
   - `both` — set as both `coverImage` and `thumbnailImage`
   - `body` — insert as an inline image within the post body
4. **Orientation** (optional): `landscape` (default, best for covers), `portrait`, or `squarish`

If the user has already provided this information, proceed directly to Step 1.

---

### Step 1: Locate the Target Post

1. Find the blog post file. If the user gave a slug, search for it:
   ```bash
   grep -rl 'slug = "the-slug"' content/post/
   ```
2. Read the post to confirm it exists and note its current frontmatter (especially existing `coverImage`/`thumbnailImage` values).
3. Extract the post's date (`YYYY/MM`) from frontmatter to determine the correct image directory.

---

### Step 2: Search Unsplash

Query the Unsplash API to find relevant photos:

```bash
curl -s "https://api.unsplash.com/search/photos?query=QUERY&orientation=ORIENTATION&per_page=5" \
  -H "Authorization: Client-ID ${UNSPLASH_ACCESS_KEY}"
```

Parameters:
- `query`: The user's search term (URL-encoded)
- `orientation`: `landscape` (default), `portrait`, or `squarish`
- `per_page`: 5 (show a manageable selection)

From the response, extract for each result:
- `id`: Photo ID
- `description` or `alt_description`: For alt text
- `urls.regular`: Preview URL (1080px wide — good for display)
- `urls.small`: Smaller preview for quick viewing
- `links.download_location`: **Required** for triggering a download (Unsplash API guidelines)
- `user.name`: Photographer's name
- `user.links.html`: Photographer's Unsplash profile URL

Present the results to the user with numbered options. For each photo, show:
- A brief description
- The photographer's name
- The preview URL so they can check it in a browser

Ask the user to pick one.

---

### Step 3: Download the Image

Once the user selects a photo:

1. **Trigger the download endpoint** (required by Unsplash API guidelines):
   ```bash
   curl -s "${download_location}?client_id=${UNSPLASH_ACCESS_KEY}" > /dev/null
   ```

2. **Download the actual image** using the `urls.regular` URL (1080px wide, good balance of quality and file size):
   ```bash
   curl -sL "${urls_regular}" -o "static/images/YYYY/MM/FILENAME.jpg"
   ```

3. **File naming convention**:
   - Use a descriptive kebab-case name based on the search query or photo description
   - Example: `server-rack-unsplash.jpg`
   - For cover images that need a wider variant, the same file works — the theme handles sizing via CSS
   - Suffix with `-unsplash` to make the source obvious

4. **Create the directory** if it doesn't exist:
   ```bash
   mkdir -p static/images/YYYY/MM/
   ```

---

### Step 4: Update the Blog Post

#### Update Frontmatter

Based on the image usage specified in Step 0:

- **cover**: Set `coverImage = "/images/YYYY/MM/FILENAME.jpg"`
- **thumbnail**: Set `thumbnailImage = "/images/YYYY/MM/FILENAME.jpg"`
- **both**: Set both `coverImage` and `thumbnailImage` to the same path
- **body**: Do not modify frontmatter (image goes in the post body instead)

If the post already has a `coverImage` or `thumbnailImage` value, confirm with the user before overwriting.

#### Add Attribution

Unsplash requires attribution. Add a comment at the bottom of the post (or update an existing attribution section):

```markdown
---

*Cover photo by [Photographer Name](photographer_profile_url) on [Unsplash](https://unsplash.com)*
```

For **body** images, add the attribution directly below the image:

```markdown
![Descriptive alt text](/images/YYYY/MM/FILENAME.jpg)
*Photo by [Photographer Name](photographer_profile_url) on [Unsplash](https://unsplash.com)*
```

Use the `alt_description` from the Unsplash API response as the alt text (clean it up if needed).

---

### Step 5: Verify

1. **Check the image file exists** and has a reasonable file size:
   ```bash
   ls -lh static/images/YYYY/MM/FILENAME.jpg
   ```

2. **Verify the frontmatter** is valid TOML with correct image paths.

3. **Run the Hugo build** to confirm no errors:
   ```bash
   hugo --buildDrafts --quiet
   ```

4. **Report to the user**:
   - Image saved to: `static/images/YYYY/MM/FILENAME.jpg`
   - Image set as: cover / thumbnail / both / body
   - Attribution added for: Photographer Name
   - Suggest previewing with: `hugo server --buildDrafts`

---

## Important Notes

- **Always trigger the download endpoint** before downloading — this is required by the Unsplash API Terms of Service
- **Always add attribution** — this is required by the Unsplash licence
- **Never hotlink** to Unsplash URLs in the blog post — always download and serve locally
- The GitHub Actions image optimisation workflow will automatically compress the image on commit, so no manual optimisation is needed
- If `UNSPLASH_ACCESS_KEY` is not set, do not proceed — ask the user to set it first
