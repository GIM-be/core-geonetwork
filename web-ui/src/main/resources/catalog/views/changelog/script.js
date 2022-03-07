/*jshint esversion: 6 */

(function () {
  "use strict";

  let target;
  let timeout;

  function createSummary() {
    let sections = document.querySelectorAll('.container section');
    let summary = document.getElementById('summary');
    sections.forEach(function (section) {
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
      newTarget = document.getElementById(decodeURI(hash));
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

  function formatBulletTables() {
    document.querySelectorAll('.bullet-table tr').forEach(row => {
      const bullet = document.createElement('td');
      bullet.textContent = '•';
      const arrow = document.createElement('td');
      arrow.textContent = ' ➔ ';
      row.insertBefore(bullet, row.children[0]);
      row.insertBefore(arrow, row.children[2]);
    });
  }

  window.onhashchange = updateSelected;
  window.onload = function () {
    createSummary();
    updateSelected();
    formatBulletTables();
  };
})();

