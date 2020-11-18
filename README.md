# Gitlab Lint Client :: A Ruby CLI And Pre-Commit Hook For Validating GitLab CI YAML Files

The author has some [repositories](https://gitlab.com/groups/sppears_grp/-/shared) at GitLab.
Occasionaly *.gitlab-ci.yml* files containing syntax errors would be committed accidentally, 
breaking the CI build.

GitLab provide a web form interface, available per project for linting. However, this started
to be cumbersome and became a candidate for automation via the GitLab API and git hooks. 
Unfortunately, the free plan for gitlab.com does not feature *pre-receive* git server hooks which
could prevent pushes containing invalid *.gitlab-ci.yml* files. 

Git provides, a *pre-commit* hook that runs for staged files on the local development environment.
While use of local git hooks are not easily enforced, it is better than the alternative in this case. 
The [pre-commit](https://pre-commit.com/) project facilitates deployment and installation of 
client side git hooks. 


## 🔎 What Does This Repository Offer?

The author developed a Ruby CLI and library to lint GitLab yaml files containing CI 
Pipeline specifications. Linting is performed using the GitLab API. 

The gem is served on [rubygems.org](https://rubygems.org) as *gitlab-lint-client* and the 
source code, with accompanying unit and functional tests, are held within this repository. 
It can be installed by issuing the following command: 
```gem install gitlab-lint-client```. 

Usage details are provided with the *help* option of the CLI, <kbd>glab-lint --help</kbd>
Examples are:

``` bash
# mandatory options
glab-lint --yaml=.gitlab-ci.yml --base-url=https://gitlab.com
glab-lint -f .gitlab-ci.yml -u https://gitlab.com

# configure timeout in seconds, for API request
glab-lint --yaml=.gitlab-ci.yml --base-url=https://gitlab.com --timeout=10
glab-lint -f .gitlab-ci.yml -u https://gitlab.com -t 10

# display program version number and exit
glab-lint --version
glab-lint -v 
```

The author is using the gem within a client side pre-commit hook to automate GitLab CI linting.


## 🔐 Usage As A Pre-Commit Hook

This repository specifies a pre-commit hook in the *.pre-commit-hooks.yml* file. Developers can
configure their GitLab repositories to use this hook by creating a *.pre-commit-config.yaml* file
in the root of their repository.

``` yaml
repos:
- repo: https://github.com/dcs3spp/validate-gitlab-ci
  rev: v0.0.1
  hooks:
  - id: validate-gitlab-ci
    args: [--yaml=.gitlab-ci.yml, --base-url=https://gitlab.com]
    pass_filenames: false
    types: [yaml]
    files: .gitlab-ci.yml
    stages: [commit]
```

Subsequently, [install](https://pre-commit.com/#installation) the pre-commit tool by issuing
the following command:

``` bash
pip install pre-commit
```

Instruct pre-commit to download and configure the hooks defined in the *.pre-commit-config.yaml* file:

``` bash
pre-commit install
```

This will create a Ruby environment and automatically download and install the gem held within this 
repository. The environment is setup on first time use only.

Subsequently, whenever an attempt is made to commit the GitLab CI yaml file, the pre-commit hook
will automatically send it for linting to the GitLab API. If a failed response is received from the API,
then the commit is declined. 


## 🔧 Quick Start For Development

Perform a *git clone*:
``` bash
git clone --depth 1 https://github.com/dcs3spp/validate-gitlab-ci.git
```

* This will download the source to local machine. 
* Ruby >=2.3.6 is required with the following development dependencies:
    * bundler
    * pry
    * rake
    * rspec
    * webmock

* The gemspec file lists specific dependencies for development.
* This gem is available publically as *gitlab-lint-client*


## 🏭 Building And Installing The Gem Locally

``` bash
gem build gitlab-lint-client.gemspec
gem install gitlab-lint-client-0.0.1.gem
```

## ⛑ Running Tests Locally

``` bash
bundle exec rspec
```

## 📁 Environment Variables

**Name**  |  **Description**
:---:  |  :---:
**GITLAB_API_TOKEN**  |  GitLab API Token for use with private GitLab servers (other than https://gitlab.com) that may require an authorization header 


## 📦 Using Rake For Performing A Release

``` bash
# build the gem
rake build

# install the gem
rake install

# run the tests
rake spec

# release the gem
rake release
```


## 📋 Versioning

- [CHANGELOG](CHANGELOG.md)


## 🔑 License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
