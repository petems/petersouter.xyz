/**
 * Unit tests for talks filtering functionality
 */

const {
  toggleFilterGroup,
  toggleFilter,
  clearFilters,
  shouldShowTalk,
  applyFilters,
  resetFilters,
  getActiveFilters
} = require('../static/js/talks-filter.js');

describe('Talks Filter Logic', () => {
  beforeEach(() => {
    // Reset filters before each test
    resetFilters();

    // Set up a basic DOM structure
    document.body.innerHTML = `
      <div class="talks-container">
        <div class="filter-group collapsed">
          <label>Filter by Year:</label>
          <div class="filter-content collapsed">
            <span class="filter-tag year-filter" data-year="2026">2026</span>
            <span class="filter-tag year-filter" data-year="2025">2025</span>
          </div>
        </div>

        <div id="visible-count">0</div>

        <div class="talks-list">
          <div class="talk-item"
               data-year="2026"
               data-conference="Config Management Camp"
               data-topics="CI/CD,Testing">
            Talk 1
          </div>
          <div class="talk-item"
               data-year="2025"
               data-conference="TestCon Europe"
               data-topics="CI/CD,Performance">
            Talk 2
          </div>
          <div class="talk-item"
               data-year="2020"
               data-conference="TestCon Europe"
               data-topics="Testing,Infrastructure as Code">
            Talk 3
          </div>
        </div>
      </div>
    `;
  });

  describe('shouldShowTalk', () => {
    it('should show talk when no filters are active', () => {
      const talkData = {
        year: '2026',
        conference: 'Config Management Camp',
        topics: ['CI/CD', 'Testing']
      };
      const filters = {
        year: new Set(),
        conference: new Set(),
        topic: new Set()
      };

      expect(shouldShowTalk(talkData, filters)).toBe(true);
    });

    it('should show talk when year filter matches', () => {
      const talkData = {
        year: '2026',
        conference: 'Config Management Camp',
        topics: ['CI/CD', 'Testing']
      };
      const filters = {
        year: new Set(['2026']),
        conference: new Set(),
        topic: new Set()
      };

      expect(shouldShowTalk(talkData, filters)).toBe(true);
    });

    it('should hide talk when year filter does not match', () => {
      const talkData = {
        year: '2026',
        conference: 'Config Management Camp',
        topics: ['CI/CD', 'Testing']
      };
      const filters = {
        year: new Set(['2025']),
        conference: new Set(),
        topic: new Set()
      };

      expect(shouldShowTalk(talkData, filters)).toBe(false);
    });

    it('should show talk when conference filter matches', () => {
      const talkData = {
        year: '2026',
        conference: 'Config Management Camp',
        topics: ['CI/CD', 'Testing']
      };
      const filters = {
        year: new Set(),
        conference: new Set(['Config Management Camp']),
        topic: new Set()
      };

      expect(shouldShowTalk(talkData, filters)).toBe(true);
    });

    it('should hide talk when conference filter does not match', () => {
      const talkData = {
        year: '2026',
        conference: 'Config Management Camp',
        topics: ['CI/CD', 'Testing']
      };
      const filters = {
        year: new Set(),
        conference: new Set(['FOSDEM']),
        topic: new Set()
      };

      expect(shouldShowTalk(talkData, filters)).toBe(false);
    });

    it('should show talk when at least one topic matches', () => {
      const talkData = {
        year: '2026',
        conference: 'Config Management Camp',
        topics: ['CI/CD', 'Testing', 'DevOps']
      };
      const filters = {
        year: new Set(),
        conference: new Set(),
        topic: new Set(['Testing'])
      };

      expect(shouldShowTalk(talkData, filters)).toBe(true);
    });

    it('should hide talk when no topics match', () => {
      const talkData = {
        year: '2026',
        conference: 'Config Management Camp',
        topics: ['CI/CD', 'Testing']
      };
      const filters = {
        year: new Set(),
        conference: new Set(),
        topic: new Set(['Security'])
      };

      expect(shouldShowTalk(talkData, filters)).toBe(false);
    });

    it('should handle multiple filters (AND logic)', () => {
      const talkData = {
        year: '2026',
        conference: 'Config Management Camp',
        topics: ['CI/CD', 'Testing']
      };
      const filters = {
        year: new Set(['2026']),
        conference: new Set(['Config Management Camp']),
        topic: new Set(['Testing'])
      };

      expect(shouldShowTalk(talkData, filters)).toBe(true);
    });

    it('should hide talk when one filter does not match', () => {
      const talkData = {
        year: '2026',
        conference: 'Config Management Camp',
        topics: ['CI/CD', 'Testing']
      };
      const filters = {
        year: new Set(['2025']), // Wrong year
        conference: new Set(['Config Management Camp']),
        topic: new Set(['Testing'])
      };

      expect(shouldShowTalk(talkData, filters)).toBe(false);
    });

    it('should trim whitespace from topics', () => {
      const talkData = {
        year: '2026',
        conference: 'Config Management Camp',
        topics: [' CI/CD ', ' Testing ']
      };
      const filters = {
        year: new Set(),
        conference: new Set(),
        topic: new Set(['CI/CD'])
      };

      expect(shouldShowTalk(talkData, filters)).toBe(true);
    });

    it('should handle empty topics array', () => {
      const talkData = {
        year: '2026',
        conference: 'Config Management Camp',
        topics: []
      };
      const filters = {
        year: new Set(),
        conference: new Set(),
        topic: new Set(['Testing'])
      };

      expect(shouldShowTalk(talkData, filters)).toBe(false);
    });
  });

  describe('toggleFilter', () => {
    it('should add filter when not active', () => {
      const element = document.querySelector('[data-year="2026"]');
      toggleFilter(element, 'year');

      const filters = getActiveFilters();
      expect(filters.year.has('2026')).toBe(true);
      expect(element.classList.contains('active')).toBe(true);
    });

    it('should remove filter when already active', () => {
      const element = document.querySelector('[data-year="2026"]');

      // Add filter first
      toggleFilter(element, 'year');
      expect(getActiveFilters().year.has('2026')).toBe(true);

      // Remove filter
      toggleFilter(element, 'year');
      expect(getActiveFilters().year.has('2026')).toBe(false);
      expect(element.classList.contains('active')).toBe(false);
    });

    it('should handle multiple filters of same type', () => {
      const element2026 = document.querySelector('[data-year="2026"]');
      const element2025 = document.querySelector('[data-year="2025"]');

      toggleFilter(element2026, 'year');
      toggleFilter(element2025, 'year');

      const filters = getActiveFilters();
      expect(filters.year.has('2026')).toBe(true);
      expect(filters.year.has('2025')).toBe(true);
    });
  });

  describe('clearFilters', () => {
    it('should clear all active filters', () => {
      const element = document.querySelector('[data-year="2026"]');
      toggleFilter(element, 'year');

      expect(getActiveFilters().year.size).toBe(1);

      clearFilters();

      const filters = getActiveFilters();
      expect(filters.year.size).toBe(0);
      expect(filters.conference.size).toBe(0);
      expect(filters.topic.size).toBe(0);
    });

    it('should remove active class from all filter tags', () => {
      const element = document.querySelector('[data-year="2026"]');
      element.classList.add('active');

      clearFilters();

      expect(element.classList.contains('active')).toBe(false);
    });
  });

  describe('applyFilters', () => {
    it('should show all talks when no filters are active', () => {
      applyFilters();

      const talks = document.querySelectorAll('.talk-item');
      talks.forEach(talk => {
        expect(talk.classList.contains('hidden')).toBe(false);
      });

      expect(document.getElementById('visible-count').textContent).toBe('3');
    });

    it('should filter talks by year', () => {
      const element = document.querySelector('[data-year="2026"]');
      toggleFilter(element, 'year');

      const talks = document.querySelectorAll('.talk-item');
      expect(talks[0].classList.contains('hidden')).toBe(false); // 2026
      expect(talks[1].classList.contains('hidden')).toBe(true);  // 2025
      expect(talks[2].classList.contains('hidden')).toBe(true);  // 2020

      expect(document.getElementById('visible-count').textContent).toBe('1');
    });

    it('should filter talks by multiple years', () => {
      // Manually add filters since we need multiple years
      const filters = getActiveFilters();
      filters.year.add('2026');
      filters.year.add('2025');

      applyFilters();

      const talks = document.querySelectorAll('.talk-item');
      expect(talks[0].classList.contains('hidden')).toBe(false); // 2026
      expect(talks[1].classList.contains('hidden')).toBe(false); // 2025
      expect(talks[2].classList.contains('hidden')).toBe(true);  // 2020

      expect(document.getElementById('visible-count').textContent).toBe('2');
    });

    it('should filter talks by conference', () => {
      const filters = getActiveFilters();
      filters.conference.add('TestCon Europe');

      applyFilters();

      const talks = document.querySelectorAll('.talk-item');
      expect(talks[0].classList.contains('hidden')).toBe(true);  // Config Management Camp
      expect(talks[1].classList.contains('hidden')).toBe(false); // TestCon Europe
      expect(talks[2].classList.contains('hidden')).toBe(false); // TestCon Europe

      expect(document.getElementById('visible-count').textContent).toBe('2');
    });

    it('should filter talks by topic', () => {
      const filters = getActiveFilters();
      filters.topic.add('Testing');

      applyFilters();

      const talks = document.querySelectorAll('.talk-item');
      expect(talks[0].classList.contains('hidden')).toBe(false); // Has Testing
      expect(talks[1].classList.contains('hidden')).toBe(true);  // No Testing
      expect(talks[2].classList.contains('hidden')).toBe(false); // Has Testing

      expect(document.getElementById('visible-count').textContent).toBe('2');
    });

    it('should combine multiple filter types (AND logic)', () => {
      const filters = getActiveFilters();
      filters.year.add('2025');
      filters.topic.add('CI/CD');

      applyFilters();

      const talks = document.querySelectorAll('.talk-item');
      expect(talks[0].classList.contains('hidden')).toBe(true);  // 2026
      expect(talks[1].classList.contains('hidden')).toBe(false); // 2025 + CI/CD
      expect(talks[2].classList.contains('hidden')).toBe(true);  // 2020

      expect(document.getElementById('visible-count').textContent).toBe('1');
    });

    it('should update visible count correctly', () => {
      expect(document.getElementById('visible-count').textContent).toBe('0');

      applyFilters();
      expect(document.getElementById('visible-count').textContent).toBe('3');

      const filters = getActiveFilters();
      filters.year.add('2026');
      applyFilters();
      expect(document.getElementById('visible-count').textContent).toBe('1');
    });

    it('should handle missing visible-count element gracefully', () => {
      document.getElementById('visible-count').remove();

      expect(() => applyFilters()).not.toThrow();
    });
  });

  describe('toggleFilterGroup', () => {
    it('should toggle collapsed class on filter group', () => {
      const label = document.querySelector('.filter-group label');
      const filterGroup = label.parentElement;

      expect(filterGroup.classList.contains('collapsed')).toBe(true);

      toggleFilterGroup(label);
      expect(filterGroup.classList.contains('collapsed')).toBe(false);

      toggleFilterGroup(label);
      expect(filterGroup.classList.contains('collapsed')).toBe(true);
    });

    it('should toggle collapsed class on filter content', () => {
      const label = document.querySelector('.filter-group label');
      const filterContent = label.parentElement.querySelector('.filter-content');

      expect(filterContent.classList.contains('collapsed')).toBe(true);

      toggleFilterGroup(label);
      expect(filterContent.classList.contains('collapsed')).toBe(false);

      toggleFilterGroup(label);
      expect(filterContent.classList.contains('collapsed')).toBe(true);
    });
  });

  describe('Edge Cases', () => {
    it('should handle talks with no topics', () => {
      document.body.innerHTML += `
        <div class="talk-item"
             data-year="2019"
             data-conference="DevOps.lt"
             data-topics="">
          Talk with no topics
        </div>
      `;

      const filters = getActiveFilters();
      filters.topic.add('Security');

      expect(() => applyFilters()).not.toThrow();
    });

    it('should handle missing data-topics attribute', () => {
      const talkWithoutTopics = document.createElement('div');
      talkWithoutTopics.className = 'talk-item';
      talkWithoutTopics.dataset.year = '2019';
      talkWithoutTopics.dataset.conference = 'DevOps.lt';
      // No data-topics attribute set
      document.querySelector('.talks-list').appendChild(talkWithoutTopics);

      const filters = getActiveFilters();
      filters.topic.add('Security');

      expect(() => applyFilters()).not.toThrow();

      // Talk without topics should be hidden when topic filter is active
      expect(talkWithoutTopics.classList.contains('hidden')).toBe(true);
    });

    it('should handle empty topics after split (empty string topics)', () => {
      document.body.innerHTML += `
        <div class="talk-item"
             data-year="2019"
             data-conference="DevOps.lt"
             data-topics=",,">
          Talk with only commas
        </div>
      `;

      expect(() => applyFilters()).not.toThrow();

      // Should show when no filters active
      const talk = document.querySelector('[data-topics=",,"]');
      expect(talk.classList.contains('hidden')).toBe(false);

      // Should hide when topic filter active
      const filters = getActiveFilters();
      filters.topic.add('Security');
      applyFilters();
      expect(talk.classList.contains('hidden')).toBe(true);
    });

    it('should normalize topics with extra whitespace', () => {
      document.body.innerHTML += `
        <div class="talk-item"
             data-year="2019"
             data-conference="DevOps.lt"
             data-topics=" CI/CD , Testing , ">
          Talk with whitespace
        </div>
      `;

      const filters = getActiveFilters();
      filters.topic.add('CI/CD');

      applyFilters();

      const talk = document.querySelector('[data-topics=" CI/CD , Testing , "]');
      expect(talk.classList.contains('hidden')).toBe(false);
    });

    it('should filter out empty strings from topics array', () => {
      document.body.innerHTML += `
        <div class="talk-item"
             data-year="2019"
             data-conference="DevOps.lt"
             data-topics="Testing,,DevOps, ,Security">
          Talk with empty entries
        </div>
      `;

      const filters = getActiveFilters();
      filters.topic.add('Testing');

      applyFilters();

      const talk = document.querySelector('[data-topics="Testing,,DevOps, ,Security"]');
      expect(talk.classList.contains('hidden')).toBe(false);
    });

    it('should handle special characters in filter values', () => {
      document.body.innerHTML += `
        <div class="talk-item"
             data-year="2019"
             data-conference="Config Management Camp"
             data-topics="CI/CD,Infrastructure as Code">
          Talk with special chars
        </div>
      `;

      const filters = getActiveFilters();
      filters.topic.add('Infrastructure as Code');

      applyFilters();

      const talk = document.querySelector('[data-topics="CI/CD,Infrastructure as Code"]');
      expect(talk.classList.contains('hidden')).toBe(false);
    });

    it('should handle case sensitivity in topics', () => {
      const talkData = {
        year: '2026',
        conference: 'Config Management Camp',
        topics: ['ci/cd', 'Testing']
      };
      const filters = {
        year: new Set(),
        conference: new Set(),
        topic: new Set(['CI/CD'])
      };

      // Topics are case-sensitive by default
      expect(shouldShowTalk(talkData, filters)).toBe(false);
    });
  });

  describe('resetFilters', () => {
    it('should reset all filters to empty sets', () => {
      const filters = getActiveFilters();
      filters.year.add('2026');
      filters.conference.add('FOSDEM');
      filters.topic.add('Security');

      resetFilters();

      const newFilters = getActiveFilters();
      expect(newFilters.year.size).toBe(0);
      expect(newFilters.conference.size).toBe(0);
      expect(newFilters.topic.size).toBe(0);
    });
  });
});
