import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"
import Fuse from "fuse.js"

export default class extends Controller {
  static targets = [
    'article',
    'directory',
    'feed',
    'modalKeyboardHelpEl',
    'modalSearchBoxEl',
    'searchBox',
    'searchResults'
  ]

  initialize() {
    this.searchBoxOpen = false
    this.shortcutHandlers = {
      '?': this.toggleHelp,
      'j': () => nextArticle(true),
      'k': () => previousArticle(true),
      'n': this.nextArticle,
      'p': this.previousArticle,
      'v': this.openCurrentTab,
      'b': () => this.openCurrentTab(true),
      's': this.starCurrentArticle,
      'm': this.markReadCurrentArticle,
      'A': this.markArticlesReadCurrentView,
      'a': this.navigateToAllView,
      'S': this.navigateToStarView,
      'u': this.openSearchBox
    };
  }

  connect() {
    this.modalKeyboardHelp = new bootstrap.Modal(this.modalKeyboardHelpElTarget)
    this.modalSearchBox = new bootstrap.Modal(this.modalSearchBoxElTarget)
    this.extractSearchItems()
  }

  extractSearchItems() {
    this.searchItems = [];
    this.feedTargets.forEach((el) => {
      this.searchItems.push({
        id: el.dataset.feedId,
        title: el.dataset.feedTitle,
        type: 'feed'
      })
    });
    this.directoryTargets.forEach((el) => {
      this.searchItems.push({
        id: el.dataset.directoryId,
        title: el.dataset.directoryTitle,
        type: 'directory'
      })
    });
    this.fuse = new Fuse(this.searchItems, {keys: ['title']})
  }

  toggleHelp() {
    this.modalKeyboardHelp.toggle()
  }

  closeHelp() {
    this.searchBoxOpen = false
  }

  nextArticle() {

  }

  previousArticle() {

  }

  openCurrentTab() {

  }

  starCurrentArticle() {

  }

  markReadCurrentArticle() {

  }

  markArticlesReadCurrentView() {

  }

  navigateToAllView() {

  }

  navigateToStarView() {

  }

  searchInput(event) {
    this.searchResults = this.fuse.search(this.searchBoxTarget.value)

    const resultsHtml = this.searchResults.map((r) => {
      return `<li>${r.item.title}&nbsp;-&nbsp;<small class="search-sub-type">${r.item.type}</small></li>`
    })

    const resultsTemplate = `
      <br/>
      <ul class="search-results">
        ${resultsHtml.join('')}
      </ul>`
    this.searchResultsTarget.innerHTML = resultsTemplate
  }

  seachSubmit(event) {
    event.preventDefault && event.preventDefault();
    // TODO select the current not just the first
    let target = this.searchResults[0]?.item
    this.searchResults = [];
    this.searchOpen = false;
    if(target) {
      Turbo.visit(`/${target.type === 'directory' ? 'directories' : 'feeds'}/${target.id}`)
    }
  }

  openSearchBox() {
    this.modalSearchBox.show()
    this.searchBoxOpen = true
    setTimeout(() => {
      this.searchBoxTarget.focus();
    }, 500);
  }

  handleKeydown(event) {
    //TODO make sure to disable scroll spy here
    // disableScrollSpy = true;
    if(this.searchBoxOpen) {
      return; // ignore these when we're searching
    }
    const handler = this.shortcutHandlers[event.key];
    if(typeof handler === "function") {
      handler.call(this);
    }
  }

  async logout() {
    const csrf = document.querySelector('meta[name="csrf-token"]').attributes["content"].textContent
    console.log('try me')
    await fetch("/users/sign_out",
      {
        method: "DELETE",
        headers: {
          "X-CSRF-Token": csrf
        }
      }
    )
    Turbo.visit("/")
  }
}
