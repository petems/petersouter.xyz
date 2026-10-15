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
 * @param {HTMLElement} label - The label element that was clicked
 */
function toggleFilterGroup(label) {
  const filterGroup = label.parentElement;
  const filterContent = filterGroup.querySelector('.filter-content');

  filterGroup.classList.toggle('collapsed');
  filterContent.classList.toggle('collapsed');
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
  } else {
    activeFilters[type].add(value);
    element.classList.add('active');
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
 * Applies the current filters to all talks
 */
function applyFilters() {
  const talks = document.querySelectorAll('.talk-item');
  let visibleCount = 0;

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
      talk.classList.remove('hidden');
      visibleCount++;
    } else {
      talk.classList.add('hidden');
    }
  });

  const visibleCountElement = document.getElementById('visible-count');
  if (visibleCountElement) {
    visibleCountElement.textContent = visibleCount;
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

// Export for testing (Node.js/Jest environment)
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    toggleFilterGroup,
    toggleFilter,
    clearFilters,
    shouldShowTalk,
    applyFilters,
    resetFilters,
    getActiveFilters
  };
}
