<template>
  <Teleport to="body">
    <Transition name="help-overlay">
      <div v-if="open" class="help-overlay" @click.self="$emit('close')" />
    </Transition>
    <Transition name="help-panel">
      <aside v-if="open" class="help-panel" role="complementary" aria-label="Help">
        <div class="help-header">
          <h3 class="help-title">Help — {{ pageTitle }}</h3>
          <button class="help-close" @click="$emit('close')" aria-label="Close help">✕</button>
        </div>

        <div class="help-search-wrap">
          <input
            v-model="query"
            class="help-search"
            type="search"
            placeholder="Search help topics…"
            aria-label="Search help"
          />
        </div>

        <div class="help-body">
          <template v-if="filteredSections.length">
            <section
              v-for="section in filteredSections"
              :key="section.title"
              class="help-section"
            >
              <h4 class="section-title">{{ section.title }}</h4>
              <ul class="section-list">
                <li v-for="item in section.items" :key="item.q" class="help-item">
                  <button class="help-q" @click="toggle(item.q)">
                    <span>{{ item.q }}</span>
                    <span class="help-chevron" :class="{ open: expanded === item.q }">›</span>
                  </button>
                  <div v-if="expanded === item.q" class="help-a" v-html="item.a" />
                </li>
              </ul>
            </section>
          </template>
          <p v-else class="help-empty">No results for "{{ query }}".</p>
        </div>

        <div class="help-footer">
          <span>Need more help?</span>
          <a href="mailto:eonmgm@gmail.com" class="help-link">Contact support</a>
        </div>
      </aside>
    </Transition>
  </Teleport>
</template>

<script setup>
import { ref, computed } from 'vue';

const props = defineProps({
  open: { type: Boolean, default: false },
  page: { type: String, default: '' },
});
defineEmits(['close']);

const query = ref('');
const expanded = ref(null);

function toggle(q) {
  expanded.value = expanded.value === q ? null : q;
}

const pageTitles = {
  'admin-dashboard': 'Dashboard',
  'admin-products': 'Products',
  'admin-categories': 'Categories',
  'admin-content': 'Content Editor',
  'admin-company': 'Company Info',
  'admin-social': 'Social Links',
  'admin-seo': 'SEO Manager',
};
const pageTitle = computed(() => pageTitles[props.page] || 'Admin Panel');

const helpContent = {
  'admin-dashboard': [
    {
      title: 'Overview',
      items: [
        { q: 'What does the Dashboard show?', a: 'The Dashboard shows a real-time summary of your catalog: total products, active categories, recent activity, and quick links to the most common tasks.' },
        { q: 'How do I navigate to a section?', a: 'Use the sidebar on the left to jump between Products, Categories, Content, and other sections. Click <strong>‹</strong> to collapse the sidebar for more screen space.' },
      ],
    },
    {
      title: 'Quick Actions',
      items: [
        { q: 'How do I add a new product quickly?', a: 'Click <strong>+ Add Product</strong> on the Dashboard or navigate to <em>Products → New</em>. Fill in the name, category, price, and at least one image, then hit Save.' },
      ],
    },
  ],
  'admin-products': [
    {
      title: 'Managing Products',
      items: [
        { q: 'How do I add a new product?', a: 'Click <strong>+ Add Product</strong>. Required fields are <em>Name</em> and <em>Category</em>. A URL-friendly slug is generated automatically from the name — you can edit it manually if needed.' },
        { q: 'How do I upload product images?', a: 'In the product form, use the <em>Images</em> section to drag-and-drop or browse for images. The first image becomes the thumbnail shown in the catalog. Supported formats: JPG, PNG, WebP. Max size: 5 MB each.' },
        { q: 'What is the "Featured" toggle?', a: 'Featured products appear in the <em>Featured Products</em> section on the homepage. Enable it for your best-selling or promoted items.' },
        { q: 'How do I add product specifications?', a: 'Use the <em>Specifications</em> section to add key-value pairs (e.g., Power → 100W). These are displayed in a table on the product detail page.' },
        { q: 'How do I edit or delete a product?', a: 'In the product list, click the <strong>✏️ Edit</strong> icon to open the edit form, or <strong>🗑️ Delete</strong> to permanently remove the product. Deletion cannot be undone.' },
        { q: 'How does search and filtering work?', a: 'Use the search bar to filter products by name or description. Use the category dropdown to show only products in a specific category. Changes apply instantly.' },
      ],
    },
    {
      title: 'Slugs and URLs',
      items: [
        { q: 'What is a slug?', a: 'A slug is the URL-friendly identifier for a product, e.g., <code>led-high-bay-100w</code>. It appears in the product page URL: <code>/products/led-high-bay-100w</code>. Slugs must be unique and contain only lowercase letters, numbers, and hyphens.' },
        { q: 'Can I change a slug after publishing?', a: 'Yes, but changing a slug breaks any existing links or bookmarks to that product. Only change it if you have not shared the URL publicly.' },
      ],
    },
  ],
  'admin-categories': [
    {
      title: 'Managing Categories',
      items: [
        { q: 'How do I create a category?', a: 'Click <strong>+ Add Category</strong>, enter a name (required) and an optional description. A slug is auto-generated. Categories are used to group products in the catalog.' },
        { q: 'Can I delete a category that has products?', a: 'The system will warn you if the category contains products. Reassign or delete those products first, then delete the empty category.' },
        { q: 'How do I reorder categories?', a: 'Categories are sorted alphabetically by default. To control display order, prefix the names (e.g., "1. Lighting", "2. Equipment") or use the slug field to control sorting.' },
      ],
    },
  ],
  'admin-content': [
    {
      title: 'Editing Page Content',
      items: [
        { q: 'Which pages can I edit?', a: 'You can edit the content body for these pages: <em>About Us</em>, <em>Contact</em>, <em>Shipping Policy</em>, and <em>Terms & Conditions</em>.' },
        { q: 'Does the editor support HTML?', a: 'Yes. The content body is stored as HTML and rendered directly on the page. You can use standard HTML tags like <code>&lt;h2&gt;</code>, <code>&lt;p&gt;</code>, <code>&lt;ul&gt;</code>, <code>&lt;strong&gt;</code>, and <code>&lt;a&gt;</code>.' },
        { q: 'How do I preview my changes?', a: 'After saving, click <strong>View Site → [Page Name]</strong> in the sidebar footer to open the live page in a new tab.' },
      ],
    },
  ],
  'admin-company': [
    {
      title: 'Company Information',
      items: [
        { q: 'What information can I update here?', a: 'You can update: <em>Company Name</em>, <em>Address</em>, <em>Phone</em>, <em>Email</em>, <em>Tagline</em>, and <em>Logo URL</em>. This information appears in the site footer and the Contact page.' },
        { q: 'How do I update the company logo?', a: 'Upload your logo to an image hosting service (or use the uploads folder via the server), then paste the full URL into the <em>Logo URL</em> field.' },
        { q: 'Where does this information appear on the site?', a: 'The company name and tagline appear in the navbar. The address, phone, and email appear in the footer and on the Contact page.' },
      ],
    },
  ],
  'admin-social': [
    {
      title: 'Social Media Links',
      items: [
        { q: 'How do I add a social media link?', a: 'Click <strong>+ Add Link</strong>. Enter the platform name (e.g., Facebook), the full URL, and an icon name (e.g., <code>facebook</code>). Set <em>Active</em> to show it on the site.' },
        { q: 'What does the "Active" toggle do?', a: 'Only active links are shown on the public site. Inactive links are hidden but remain in the database — useful for temporarily hiding a platform.' },
        { q: 'What is "Sort Order"?', a: 'Sort order controls the display sequence. Lower numbers appear first. Use integers (1, 2, 3…).' },
        { q: 'What icon names are supported?', a: 'Icon names map to icon classes in your frontend (e.g., <code>facebook</code>, <code>instagram</code>, <code>twitter</code>, <code>youtube</code>, <code>tiktok</code>). Check your CSS or icon library for available names.' },
      ],
    },
  ],
  'admin-seo': [
    {
      title: 'SEO Settings',
      items: [
        { q: 'What SEO fields can I set?', a: 'For each page you can set: <em>Meta Title</em> (shown in browser tab and search results), <em>Meta Description</em> (search snippet, ~150 chars), <em>Keywords</em>, and <em>OG Image</em> (social share image URL).' },
        { q: 'Which pages have SEO settings?', a: 'You can create SEO records for any page by its <em>Page Name</em> slug (e.g., <code>home</code>, <code>about</code>, <code>catalog</code>). The frontend reads these by page name.' },
        { q: 'How does the sitemap work?', a: 'The API automatically generates an XML sitemap at <code>/api/seo/sitemap/xml</code> that includes all product pages and category pages. Submit this URL to Google Search Console to improve indexing.' },
        { q: 'What is the OG Image?', a: 'The OG (Open Graph) image appears when someone shares your page on social media (Facebook, Twitter, LinkedIn). Use a 1200×630 px image for best results. Enter the full URL.' },
        { q: 'How long should the meta description be?', a: 'Keep it between 120–160 characters. Longer descriptions are truncated by search engines. Write a clear, compelling sentence that describes the page content.' },
      ],
    },
  ],
};

const globalFaq = [
  {
    title: 'General',
    items: [
      { q: 'How do I log out?', a: 'Click <strong>🚪 Logout</strong> at the bottom of the sidebar.' },
      { q: 'My session expired — what do I do?', a: 'JWT tokens expire after 24 hours. You will be redirected to the login page automatically. Log in again to continue.' },
      { q: 'Can multiple admins use the panel?', a: 'Currently the system uses a single admin account configured via environment variables. Contact your developer to add more accounts.' },
    ],
  },
];

const sections = computed(() => {
  const pageSections = helpContent[props.page] || [];
  return [...pageSections, ...globalFaq];
});

const filteredSections = computed(() => {
  const q = query.value.trim().toLowerCase();
  if (!q) return sections.value;
  return sections.value
    .map(s => ({
      ...s,
      items: s.items.filter(
        i => i.q.toLowerCase().includes(q) || i.a.toLowerCase().includes(q)
      ),
    }))
    .filter(s => s.items.length > 0);
});
</script>

<style scoped>
.help-overlay {
  position: fixed; inset: 0;
  background: rgba(0,0,0,0.55);
  z-index: 200;
}
.help-panel {
  position: fixed; top: 0; right: 0; bottom: 0;
  width: 400px; max-width: 95vw;
  background: var(--bg-secondary);
  border-left: 1px solid var(--border);
  z-index: 201;
  display: flex; flex-direction: column;
  box-shadow: -8px 0 32px rgba(0,0,0,0.4);
}

.help-header {
  display: flex; align-items: center; justify-content: space-between;
  padding: 1.1rem 1.25rem;
  border-bottom: 1px solid var(--border);
  flex-shrink: 0;
}
.help-title { font-size: 1rem; font-weight: 700; color: var(--green-primary); margin: 0; }
.help-close {
  background: none; color: var(--text-secondary); font-size: 1rem;
  padding: 0.3rem 0.5rem; border-radius: var(--radius);
  cursor: pointer; transition: color 0.2s;
}
.help-close:hover { color: var(--text-primary); }

.help-search-wrap { padding: 0.75rem 1.25rem; border-bottom: 1px solid var(--border); flex-shrink: 0; }
.help-search {
  width: 100%; padding: 0.5rem 0.75rem;
  background: var(--bg-card); border: 1px solid var(--border);
  border-radius: var(--radius); color: var(--text-primary);
  font-size: 0.9rem; outline: none;
}
.help-search:focus { border-color: var(--green-primary); }

.help-body { flex: 1; overflow-y: auto; padding: 0.75rem 1.25rem; }

.help-section { margin-bottom: 1.25rem; }
.section-title {
  font-size: 0.7rem; font-weight: 700; letter-spacing: 0.08em;
  text-transform: uppercase; color: var(--green-secondary);
  margin: 0 0 0.5rem;
}
.section-list { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 0.35rem; }

.help-item { border: 1px solid var(--border); border-radius: var(--radius); overflow: hidden; }
.help-q {
  width: 100%; display: flex; align-items: center; justify-content: space-between;
  padding: 0.65rem 0.85rem; background: var(--bg-card);
  color: var(--text-primary); font-size: 0.875rem; font-weight: 500;
  text-align: left; cursor: pointer; gap: 0.5rem;
  transition: background 0.15s;
}
.help-q:hover { background: var(--bg-hover, #1a1a1a); }
.help-chevron { font-size: 1.1rem; color: var(--text-muted); transition: transform 0.2s; flex-shrink: 0; }
.help-chevron.open { transform: rotate(90deg); color: var(--green-primary); }

.help-a {
  padding: 0.75rem 0.85rem;
  background: var(--bg-primary);
  color: var(--text-secondary);
  font-size: 0.85rem; line-height: 1.6;
  border-top: 1px solid var(--border);
}
.help-a :deep(strong) { color: var(--text-primary); }
.help-a :deep(code) {
  background: var(--bg-card); padding: 0.1em 0.35em;
  border-radius: 3px; font-size: 0.8em; color: var(--green-primary);
}
.help-a :deep(em) { color: var(--green-secondary); font-style: normal; font-weight: 500; }

.help-empty { color: var(--text-muted); font-size: 0.9rem; text-align: center; margin-top: 2rem; }

.help-footer {
  padding: 0.85rem 1.25rem;
  border-top: 1px solid var(--border);
  display: flex; align-items: center; gap: 0.5rem;
  font-size: 0.8rem; color: var(--text-muted); flex-shrink: 0;
}
.help-link { color: var(--green-primary); text-decoration: none; }
.help-link:hover { text-decoration: underline; }

/* Transitions */
.help-overlay-enter-active,
.help-overlay-leave-active { transition: opacity 0.2s ease; }
.help-overlay-enter-from,
.help-overlay-leave-to { opacity: 0; }

.help-panel-enter-active,
.help-panel-leave-active { transition: transform 0.25s ease; }
.help-panel-enter-from,
.help-panel-leave-to { transform: translateX(100%); }
</style>
