const wrap = document.getElementById('wrap');
const grid = document.getElementById('grid');
const closeBtn = document.getElementById('closeBtn');

window.addEventListener('message', (e) => {
  const data = e.data || {};
  if (data.type === 'toggle') {
    wrap.style.display = data.show ? 'flex' : 'none';
  }
  if (data.type === 'list') {
    renderGrid(data.vehicles || []);
  }
});

function renderGrid(list) {
  grid.innerHTML = '';
  list.slice(0, 6).forEach(v => {
    const card = document.createElement('div');
    card.className = 'card';
    card.innerHTML = `<div class="label">${v.label}</div>`;
    card.addEventListener('click', () => spawn(v.model));
    grid.appendChild(card);
  });
}

function spawn(model) {
  fetch(`https://${GetParentResourceName()}/spawn`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify({ model })
  });
}

closeBtn.addEventListener('click', () => {
  fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
});
