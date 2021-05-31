let target = undefined;
let timeout = undefined;

function createSummary() {
  let sections = document.querySelectorAll('.container section');
  let summary = document.getElementById('summary');
  sections.forEach(function(section) {
    let title = document.createElement('h3');
    title.textContent = (section.title ? section.id + ": " + section.title : section.id);
    section.prepend(title);

    let bullet = document.createElement('li');
    bullet.innerHTML = `<a href="#${section.id}">${section.id}</a>`;
    summary.append(bullet);
  });
}

function updateSelected() {
  if (target) {
    target.classList.remove('selected');
    clearTimeout(timeout);
  }
  let hash = window.location.hash;
  let newTarget = null;
  if (hash !== '') {
    hash = hash.substring(1);
    newTarget = document.getElementById(hash);
    if (newTarget) {
      newTarget.classList.add('selected');
    }
  }
  target = newTarget;
  timeout = setTimeout(function () {
    if (target) {
      target.classList.remove('selected');
    }
  }, 5000);
}

window.onhashchange = updateSelected;
window.onload = function () {
  createSummary();
  updateSelected();
};
