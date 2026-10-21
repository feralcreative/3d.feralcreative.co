function element(tag, text, className) {
  const node = document.createElement(tag);
  if (text) node.textContent = text;
  if (className) node.className = className;
  return node;
}
function input(labelText, type = 'text') {
  const label = element('label', labelText);
  const field = element('input');
  field.type = type;
  label.append(field);
  return { label, field };
}
const modelFiles = model => [...new Set([...(model.views || []), ...(model.downloads || [])].map(item => item.file))];

export class ModelAdmin {
  constructor(library) {
    this.library = library;
    this.selected = new Set();
    this.files = new Set();
    this.models = [];
    this.user = null;
    this.button = element('button', 'Manage projects', 'models-manage-toggle');
    this.button.type = 'button';
    this.button.hidden = true;
    this.button.setAttribute('aria-expanded', 'false');
    this.panel = element('section', '', 'models-admin');
    this.panel.hidden = true;
    this.panel.setAttribute('aria-label', 'Manage projects');
    const wrapper = element('div', '', 'models-admin-wrap');
    wrapper.append(this.button, this.panel);
    library.search.parentElement.before(wrapper);
    this.button.addEventListener('click', () => {
      this.panel.hidden = !this.panel.hidden;
      this.button.setAttribute('aria-expanded', String(!this.panel.hidden));
      if (!this.panel.hidden) this.load();
    });
    this.panel.append(element('h2', 'Manage projects'), element('p', 'Select projects to hide or merge. Select files to move them to another project or split them into a new one. CAD source files stay in place.'));
    const search = input('Filter projects');
    this.search = search.field;
    this.search.type = 'search';
    this.panel.append(search.label);
    const tools = element('div', '', 'models-admin-tools');
    const all = element('button', 'Select filtered');
    all.type = 'button';
    all.addEventListener('click', () => { this.filtered().forEach(model => this.selected.add(model.id)); this.render(); });
    const clear = element('button', 'Clear selection');
    clear.type = 'button';
    clear.addEventListener('click', () => { this.selected.clear(); this.files.clear(); this.render(); });
    tools.append(all, clear);
    this.count = element('span');
    tools.append(this.count);
    this.panel.append(tools);
    this.projects = element('div', '', 'models-admin-projects');
    this.panel.append(this.projects);
    this.search.addEventListener('input', () => this.render());
    const form = element('form', '', 'models-admin-form');
    const actionLabel = element('label', 'Action');
    this.action = element('select');
    for (const [value, label] of [['hide', 'Hide projects'], ['show', 'Publish projects'], ['hide-files', 'Hide selected files'], ['show-files', 'Publish selected files'], ['category', 'Change category'], ['move', 'Move selected files'], ['merge', 'Merge projects into…'], ['split', 'Split selected files into a new project']]) {
      const option = element('option', label); option.value = value; this.action.append(option);
    }
    actionLabel.append(this.action);
    this.targetLabel = element('label', 'Destination project');
    this.target = element('select');
    this.targetLabel.append(this.target);
    const title = input('New project title');
    this.titleLabel = title.label; this.title = title.field;
    const category = input('Category (use / for subcategories)');
    this.categoryLabel = category.label; this.category = category.field;
    this.explanation = element('p', '', 'models-admin-help');
    this.submit = element('button', 'Apply to selected projects');
    this.submit.type = 'submit';
    this.undo = element('button', 'Undo last change');
    this.undo.type = 'button';
    this.undo.addEventListener('click', () => this.save('undo'));
    form.append(actionLabel, this.targetLabel, this.titleLabel, this.categoryLabel, this.explanation, this.submit, this.undo);
    this.panel.append(form);
    this.message = element('p');
    this.message.setAttribute('role', 'status');
    this.panel.append(this.message);
    form.addEventListener('submit', event => { event.preventDefault(); this.save(this.action.value); });
    this.action.addEventListener('change', () => this.updateAction());
    this.updateAction();
  }
  setUser(user) {
    this.user = user;
    this.button.hidden = !user?.admin;
    if (!user?.admin) {
      this.panel.hidden = true;
      this.button.setAttribute('aria-expanded', 'false');
      this.selected.clear(); this.files.clear(); this.models = [];
      this.projects.replaceChildren(); this.target.replaceChildren();
    }
  }
  async load() {
    if (!this.user?.admin) return;
    this.message.textContent = 'Loading management library…';
    this.submit.disabled = true;
    try {
      const response = await fetch('/api/model-library/manage', { cache: 'no-store' });
      const result = await response.json();
      if (!response.ok) throw new Error(result.error || 'Admin access unavailable.');
      if (!this.user?.admin) return;
      this.models = result.catalog.models.filter(model => model.id !== 'no-model-loaded').sort((a, b) => a.title.localeCompare(b.title));
      this.revision = result.revision;
      this.undo.disabled = !result.canUndo;
      this.selected = new Set([...this.selected].filter(id => this.models.some(model => model.id === id)));
      this.files.clear();
      this.target.replaceChildren();
      for (const model of this.models) {
        const option = element('option', model.title); option.value = model.id; this.target.append(option);
      }
      this.render();
      this.message.textContent = '';
    } catch (error) { this.message.textContent = error.message; }
  }
  filtered() {
    const query = this.search.value.trim().toLocaleLowerCase();
    return this.models.filter(model => [model.title, model.id, ...(model.category || []), model.has_scad !== true ? 'needs SCAD' : model.hidden ? 'hidden' : 'published', ...modelFiles(model)].join(' ').toLocaleLowerCase().includes(query));
  }
  render() {
    const rows = this.filtered().map(model => {
      const row = element('div', '', 'models-admin-project');
      const choice = input('', 'checkbox');
      choice.field.checked = this.selected.has(model.id);
      choice.field.addEventListener('change', () => {
        if (choice.field.checked) this.selected.add(model.id);
        else { this.selected.delete(model.id); modelFiles(model).forEach(file => this.files.delete(`${model.id}\n${file}`)); }
        this.render();
      });
      choice.label.append(document.createTextNode(`${model.title} · ${model.has_scad !== true ? 'Needs SCAD' : model.hidden ? 'Hidden' : 'Published'} · ${modelFiles(model).length} ${modelFiles(model).length === 1 ? 'file' : 'files'}`));
      row.append(choice.label);
      const preview = element('button', 'Preview');
      preview.type = 'button';
      preview.addEventListener('click', () => window.modelViewer.openModal(model.id));
      row.append(preview);
      if (this.selected.has(model.id)) {
        const assets = element('details', '', 'models-admin-files');
        assets.append(element('summary', 'Choose files to move or split'));
        for (const file of modelFiles(model)) {
          const key = `${model.id}\n${file}`;
          const item = input('', 'checkbox');
          item.field.checked = this.files.has(key);
          item.label.append(document.createTextNode(`${file}${model.excluded_files?.includes(file) ? ' · Hidden' : ''}`));
          item.field.addEventListener('change', () => { item.field.checked ? this.files.add(key) : this.files.delete(key); this.updateAction(); });
          assets.append(item.label);
        }
        row.append(assets);
      }
      return row;
    });
    this.projects.replaceChildren(...rows);
    this.updateAction();
  }
  updateAction() {
    const action = this.action.value;
    this.targetLabel.hidden = !['move', 'merge'].includes(action);
    this.titleLabel.hidden = action !== 'split';
    this.categoryLabel.hidden = action !== 'category';
    this.count.textContent = `${this.selected.size} projects selected · ${this.files.size} files selected`;
    this.submit.disabled = !this.selected.size || (['move', 'split', 'hide-files', 'show-files'].includes(action) && !this.files.size);
    this.explanation.textContent = ({ hide: 'Hidden projects disappear from the gallery. You can publish them again here.', 'hide-files': 'Hides selected file previews and downloads without removing them from the project.', 'show-files': 'Restores selected files. The project must also be published to appear in the gallery.', show: 'Projects need a SCAD source and a supported 3D preview to appear in the gallery.', category: 'Changes the website category for every selected project.', move: 'Moves the selected files into the destination project.', merge: 'Moves all files and project details into the destination. Old project links open the destination.', split: 'Creates a hidden project containing the selected files. Review it here, then publish it.' })[action];
  }
  async save(action) {
    if (!this.user?.admin) return;
    this.submit.disabled = this.undo.disabled = true;
    this.message.textContent = 'Saving…';
    try {
      const response = await fetch('/api/model-library/manage', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ revision: this.revision, action, ids: [...this.selected], files: [...new Set([...this.files].map(key => key.split('\n')[1]))], target: this.target.value, title: this.title.value, category: this.category.value }),
      });
      const result = await response.json();
      if (!response.ok) throw new Error(result.error || 'Could not save changes.');
      if (!this.user?.admin) return;
      this.selected.clear(); this.files.clear();
      await this.load();
      await this.library.load();
      this.message.textContent = action === 'undo' ? 'Last change undone.' : 'Changes saved.';
    } catch (error) {
      this.message.textContent = error.message;
      this.updateAction();
      // A stale revision needs fresh state before another write.
      this.undo.disabled = true;
      const reload = element('button', 'Reload management library');
      reload.type = 'button'; reload.addEventListener('click', () => this.load()); this.message.append(' ', reload);
    }
  }
}
