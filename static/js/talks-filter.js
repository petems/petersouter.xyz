/**
 * Talks filtering functionality for conference talks page
 */

// Initialize active filters
let activeFilters = {
  year: new Set(),
  conference: new Set(),
  topic: new Set()
};

/**
 * Toggles visibility of a filter group (collapse/expand)
 * @param {HTMLElement} button - The button element that was clicked
 */
function toggleFilterGroup(button) {
  const filterGroup = button.parentElement;
  const filterContent = filterGroup.querySelector('.filter-content');
  const isCollapsed = filterGroup.classList.toggle('collapsed');

  filterContent.classList.toggle('collapsed');
  filterContent.setAttribute('aria-hidden', String(isCollapsed));
  button.setAttribute('aria-expanded', String(!isCollapsed));
}

/**
 * Toggles a filter on/off and applies filters
 * @param {HTMLElement} element - The filter tag element
 * @param {string} type - The filter type (year, conference, or topic)
 */
function toggleFilter(element, type) {
  const value = element.dataset[type];

  if (activeFilters[type].has(value)) {
    activeFilters[type].delete(value);
    element.classList.remove('active');
    element.setAttribute('aria-pressed', 'false');
  } else {
    activeFilters[type].add(value);
    element.classList.add('active');
    element.setAttribute('aria-pressed', 'true');
  }

  applyFilters();
}

/**
 * Clears all active filters
 */
function clearFilters() {
  activeFilters = {
    year: new Set(),
    conference: new Set(),
    topic: new Set()
  };

  document.querySelectorAll('.filter-tag').forEach(tag => {
    tag.classList.remove('active');
    if (tag.hasAttribute('aria-pressed')) {
      tag.setAttribute('aria-pressed', 'false');
    }
  });

  applyFilters();
}

/**
 * Determines if a talk should be shown based on active filters
 * @param {Object} talkData - The talk's data attributes
 * @param {Object} filters - The active filter sets
 * @returns {boolean} - True if the talk should be shown
 */
function shouldShowTalk(talkData, filters) {
  const { year, conference, topics } = talkData;

  // Check year filter
  if (filters.year.size > 0 && !filters.year.has(year)) {
    return false;
  }

  // Check conference filter
  if (filters.conference.size > 0 && !filters.conference.has(conference)) {
    return false;
  }

  // Check topic filter (match any topic)
  if (filters.topic.size > 0) {
    const hasMatchingTopic = topics.some(topic =>
      filters.topic.has(topic.trim())
    );
    if (!hasMatchingTopic) {
      return false;
    }
  }

  return true;
}

/**
 * Checks if user prefers reduced motion
 * @returns {boolean}
 */
function prefersReducedMotion() {
  return typeof window !== 'undefined' &&
    window.matchMedia &&
    window.matchMedia('(prefers-reduced-motion: reduce)').matches;
}

/**
 * Applies the current filters to all talks with staggered reveal
 */
function applyFilters() {
  const talks = document.querySelectorAll('.talk-item');
  let visibleCount = 0;
  let staggerIndex = 0;
  const useStagger = !prefersReducedMotion();

  talks.forEach(talk => {
    // Guard for absent or empty topics and normalize values
    const talkTopics = talk.dataset.topics
      ? talk.dataset.topics.split(',').map(t => t.trim()).filter(t => t !== '')
      : [];

    const talkData = {
      year: talk.dataset.year,
      conference: talk.dataset.conference,
      topics: talkTopics
    };

    const show = shouldShowTalk(talkData, activeFilters);

    if (show) {
      if (talk.classList.contains('hidden')) {
        // Stagger the reveal of newly visible cards
        if (useStagger) {
          talk.style.transitionDelay = (staggerIndex * 30) + 'ms';
        }
        talk.classList.remove('hidden');
        staggerIndex++;

        // Clean up delay after transition completes
        if (useStagger) {
          talk.addEventListener('transitionend', () => {
            talk.style.transitionDelay = '';
          }, { once: true });
        }
      }
      visibleCount++;
    } else {
      talk.style.transitionDelay = '';
      talk.classList.add('hidden');
    }
  });

  const visibleCountElement = document.getElementById('visible-count');
  if (visibleCountElement) {
    visibleCountElement.textContent = visibleCount;
  }

  // Show/hide the clear button next to the count
  const hasActiveFilters = activeFilters.year.size > 0 ||
    activeFilters.conference.size > 0 ||
    activeFilters.topic.size > 0;

  const clearButtons = document.querySelectorAll('.results-count .filter-tag.clear');
  clearButtons.forEach(btn => {
    btn.style.display = hasActiveFilters ? '' : 'none';
  });

  // Show/hide empty state
  const noResults = document.querySelector('.no-results');
  if (noResults) {
    noResults.style.display = (visibleCount === 0 && hasActiveFilters) ? '' : 'none';
  }
}

/**
 * Resets the filter state (for testing)
 */
function resetFilters() {
  activeFilters = {
    year: new Set(),
    conference: new Set(),
    topic: new Set()
  };
}

/**
 * Gets the current active filters (for testing)
 * @returns {Object} - The current active filters
 */
function getActiveFilters() {
  return activeFilters;
}

/**
 * Bind event listeners when DOM is ready
 */
function initTalksFilters() {
  // Bind toggle buttons
  document.querySelectorAll('.filter-toggle').forEach(button => {
    button.addEventListener('click', function () {
      toggleFilterGroup(this);
    });
  });

  // Use event delegation for filter tags and clear buttons
  document.querySelector('.talks-container')?.addEventListener('click', (event) => {
    const target = event.target.closest('.filter-tag');
    if (!target) return;

    if (target.classList.contains('clear')) {
      clearFilters();
      return;
    }

    let filterType = null;
    if (target.dataset.year) filterType = 'year';
    else if (target.dataset.conference) filterType = 'conference';
    else if (target.dataset.topic) filterType = 'topic';

    if (filterType) {
      toggleFilter(target, filterType);
    }
  });
}

// Initialize when DOM is ready
if (typeof document !== 'undefined') {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initTalksFilters);
  } else {
    initTalksFilters();
  }
}

// Export for testing (Node.js/Jest environment)
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    toggleFilterGroup,
    toggleFilter,
    clearFilters,
    shouldShowTalk,
    applyFilters,
    resetFilters,
    getActiveFilters,
    initTalksFilters
  };
}
