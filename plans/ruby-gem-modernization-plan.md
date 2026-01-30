# Underpass Ruby Gem Modernization Plan

## Project Overview
**Project Name:** underpass  
**Current Version:** 0.0.7  
**Purpose:** Library that queries the Overpass API and translates responses into RGeo objects  
**Last Updated:** ~6 years ago (2018-2019 era)  

## Current State Analysis

### Ruby Version
- **Current Requirement:** `>= 2.4.0`
- **CI Ruby Version:** 2.6.x
- **Local Ruby Version:** 3.4.7
- **Status:** Ruby 2.4 reached EOL in March 2020, Ruby 2.6 reached EOL in March 2022
- **Recommendation:** Update to Ruby 3.4+ (using local 3.4.7)

### Dependencies Status

#### Runtime Dependencies
| Dependency | Current Version | Status | Recommended |
|------------|-----------------|--------|-------------|
| rgeo | 2.3.0 | Outdated | Latest stable |

#### Development Dependencies
| Dependency | Current Version | Status | Recommended |
|------------|-----------------|--------|-------------|
| guard | ~> 2.16.1 | Outdated | Latest stable |
| guard-rspec | ~> 4.7.3 | Outdated | Latest stable |
| guard-rubocop | ~> 1.4.0 | Outdated | Latest stable |
| rspec | ~> 3.8 | Outdated | Latest 3.x |
| rubocop | (in Gemfile) | Outdated | Latest stable |
| rubocop-performance | (in Gemfile) | Outdated | Latest stable |
| simplecov | (in Gemfile) | Outdated | Latest stable |
| webmock | (in Gemfile) | Outdated | Latest stable |
| coveralls_reborn | (in Gemfile) | Outdated | Latest stable |

### CI/CD Status
- **GitHub Actions:** Using outdated action versions
  - `actions/checkout@master` → Should use `@v4`
  - `actions/setup-ruby@v1` → Should use `@v1` (or newer)
  - Ruby 2.6.x → Should use 3.2+ or matrix of versions

### Code Quality Tools
- **RuboCop:** TargetRubyVersion set to 2.4 (needs update)
- **Coverage:** Uses Coveralls and SimpleCov (may need updates)

## Modernization Plan

### Phase 1: Core Updates (High Priority)

#### 1.1 Update Ruby Version Requirements
**Files to modify:**
- [`underpass.gemspec`](underpass.gemspec:29) - Update `required_ruby_version`
- [`.rubocop.yml`](.rubocop.yml:3) - Update `TargetRubyVersion`

**Changes:**
```ruby
# underpass.gemspec
s.required_ruby_version = '>= 3.4.0'

# .rubocop.yml
AllCops:
  TargetRubyVersion: 3.4
```

#### 1.2 Update Gemspec Metadata
**File:** [`underpass.gemspec`](underpass.gemspec:30)

**Changes:**
```ruby
s.rubygems_version = '>= 3.0'  # Remove specific version or update to current
```

#### 1.3 Update Runtime Dependencies
**File:** [`underpass.gemspec`](underpass.gemspec:32)

**Changes:**
```ruby
s.add_runtime_dependency 'rgeo', '~> 3.0'  # Check latest version
```

#### 1.4 Update Development Dependencies
**File:** [`underpass.gemspec`](underpass.gemspec:34-37)

**Changes:**
```ruby
s.add_development_dependency 'guard', '~> 2.18'
s.add_development_dependency 'guard-rspec', '~> 4.7'
s.add_development_dependency 'guard-rubocop', '~> 1.5'
s.add_development_dependency 'rspec', '~> 3.12'
```

#### 1.5 Update Test Dependencies in Gemfile
**File:** [`Gemfile`](Gemfile:5-11)

**Changes:**
```ruby
group :test do
  gem 'coveralls_reborn', require: false
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false  # Add if not present
  gem 'simplecov', require: false
  gem 'webmock'
end
```

### Phase 2: CI/CD Updates (High Priority)

#### 2.1 Update GitHub Actions Workflow
**File:** [`.github/workflows/gempush.yml`](.github/workflows/gempush.yml)

**Changes:**
- Update `actions/checkout@master` → `actions/checkout@v4`
- Update `actions/setup-ruby@v1` → `actions/setup-ruby@v1` (keep v1, it's still valid)
- Update Ruby version from 2.6.x to 3.2.x (or use a matrix)
- Consider adding a matrix strategy to test multiple Ruby versions

**Recommended workflow structure:**
```yaml
name: Ruby Gem

on: [push, pull_request]

jobs:
  test:
    name: Tests on Ruby ${{ matrix.ruby-version }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        ruby-version: ['3.3', '3.4']

    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby ${{ matrix.ruby-version }}
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby-version }}
          bundler-cache: true

      - name: Run tests
        run: bundle exec rspec

      - name: Run rubocop
        run: bundle exec rubocop

  publish:
    name: Publish to RubyGems
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/master' && github.event_name == 'push'
    needs: test

    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.4'

      - name: Publish to RubyGems
        run: |
          mkdir -p $HOME/.gem
          touch $HOME/.gem/credentials
          chmod 0600 $HOME/.gem/credentials
          printf -- "---\n:rubygems_api_key: ${GEM_HOST_API_KEY}\n" > $HOME/.gem/credentials
          gem build *.gemspec
          gem push *.gem
        env:
          GEM_HOST_API_KEY: ${{secrets.RUBYGEMS_AUTH_TOKEN}}
```

### Phase 3: Testing & Validation (High Priority)

#### 3.1 Install Dependencies
```bash
bundle install
```

#### 3.2 Run Test Suite
```bash
bundle exec rspec
```

#### 3.3 Run RuboCop
```bash
bundle exec rubocop
```

#### 3.4 Fix Any Issues
- Address any test failures
- Fix RuboCop violations
- Update deprecated method calls if any

### Phase 4: Documentation Updates (Medium Priority)

#### 4.1 Update README
**File:** [`README.md`](README.md)

**Potential updates:**
- Update Ruby version requirement in installation section
- Update badge links if needed
- Verify example code still works
- Update contribution guidelines if needed

#### 4.2 Update CHANGELOG
- Create or update CHANGELOG.md documenting version 0.0.8 changes

### Phase 5: Version Bump (Low Priority)

#### 5.1 Consider Semantic Versioning
**File:** [`lib/underpass/version.rb`](lib/underpass/version.rb)

**Options:**
- **Minor version bump (0.1.0):** If there are breaking changes
- **Patch version bump (0.0.8):** If only dependency updates and compatibility fixes

**Recommendation:** Start with 0.0.8 since we're primarily updating dependencies and ensuring compatibility

## Risk Assessment

### High Risk Areas
1. **RGeo API changes:** The rgeo library may have breaking API changes between 2.3.0 and latest
2. **Test compatibility:** Webmock and other testing libraries may have breaking changes
3. **RuboCop rules:** New RuboCop versions may introduce stricter rules that fail existing code

### Mitigation Strategies
1. **Test thoroughly after each dependency update**
2. **Consider incremental updates** (e.g., update to rgeo 2.4, then 2.5, etc.)
3. **Review changelogs** for major dependencies before updating
4. **Keep backups** of working versions

## Execution Order

1. ✅ Analyze project structure and current state
2. ✅ Create modernization plan
3. ⏳ Update Ruby version requirements
4. ⏳ Update gemspec file
5. ⏳ Update runtime dependencies
6. ⏳ Update development dependencies
7. ⏳ Update test dependencies
8. ⏳ Update RuboCop configuration
9. ⏳ Update GitHub Actions workflow
10. ⏳ Run bundle install
11. ⏳ Run tests and fix issues
12. ⏳ Run RuboCop and fix issues
13. ⏳ Verify build passes locally
14. ⏳ Update version number
15. ⏳ Update documentation
16. ⏳ Final validation

## Success Criteria

- [ ] All tests pass with Ruby 3.4+
- [ ] RuboCop passes with no violations
- [ ] GitHub Actions workflow passes
- [ ] No deprecation warnings
- [ ] Documentation is up to date
- [ ] Gem can be built and installed successfully

## Notes

- This project appears to be well-structured with good test coverage
- The codebase uses modern Ruby practices (frozen_string_literal, etc.)
- Guard is configured for development workflow
- Webmock is used for HTTP mocking in tests
- SimpleCov and Coveralls are configured for coverage reporting
