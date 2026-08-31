# Ruby and rbenv

`hroot` is built with [Ruby on Rails](https://rubyonrails.org), a web application framework based on the [Ruby](https://www.ruby-lang.org) programming language.

Most Linux distributions have a system Ruby package, but because Rails applications rely on specific Ruby runtime versions and C-extensions, we strongly recommend using a lightweight version manager such as **rbenv** to isolate your application's Ruby environment.

---

## 💡 Why rbenv instead of RVM?

Earlier versions of `hroot` recommended **RVM** (Ruby Version Manager). Starting with `hroot 4.0`, **rbenv** is the official recommendation for manual deployments for the following reasons:

1. **Lightweight and Non-Intrusive:**  
   Unlike RVM, which overrides shell built-ins (such as `cd`) and injects complex shell functions, `rbenv` works simply by inserting a `shims` directory into your `PATH`. It leaves your shell clean and unmodified.
2. **Reliable Automation & Background Jobs (Cron / Systemd):**  
   RVM requires special environment wrappers (`rvm-exec` or sourcing scripts) inside cron jobs or automated deployment scripts. With `rbenv`, any background job (such as `whenever` or systemd) seamlessly resolves `/home/hroot/.rbenv/shims/ruby` and `bundle` without environment loading hurdles.
3. **No Environment Variable Collisions (`GEM_HOME` / `GEM_PATH`):**  
   RVM frequently sets persistent `GEM_HOME` and `GEM_PATH` variables across user sessions. When upgrading Ruby versions, this often caused binary incompatibility warnings (*"missing extensions"* for compiled gems like `mysql2`, `puma`, or `ffi`). `rbenv` avoids setting these variables and lets Bundler handle gem isolation.
4. **Obsolete Gemsets:**  
   Gemsets are no longer needed in modern Rails ecosystems because `Bundler` and `Gemfile.lock` provide strict, per-project dependency isolation.

> [!TIP]
> **Upgrading an existing RVM server:**  
> If your server previously ran RVM, simply remove the RVM lines (`source ~/.rvm/scripts/rvm` and `export PATH="$PATH:$HOME/.rvm/bin"`) from `~/.bashrc`, `~/.bash_profile`, and `~/.profile`, and unset `GEM_HOME` and `GEM_PATH`.

---

## 1. Prerequisites (Ubuntu / Debian)

Before compiling Ruby, install the necessary development headers and build dependencies:

```bash
sudo apt update
sudo apt install -y build-essential libssl-dev libreadline-dev zlib1g-dev \
                    libyaml-dev libffi-dev libgdbm-dev libncurses5-dev \
                    libvips42 default-libmysqlclient-dev git curl
```

---

## 2. Installing rbenv and ruby-build

Clone `rbenv` and `ruby-build` into your user home directory:

```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
```

Add `rbenv` to your `~/.bashrc` and `~/.profile`:

```bash
# Add to ~/.bashrc
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - bash)"
```

Reload your shell:

```bash
source ~/.bashrc
```

Verify the installation:

```bash
rbenv -v
```

---

## 3. Installing Ruby for hroot

`hroot` defines its required Ruby version in the root [`.ruby-version`](file:///.ruby-version) file (e.g. `4.0.6`).

Install the matching Ruby version using `rbenv`:

```bash
rbenv install 4.0.6
```

Set it as the global default or let rbenv automatically pick it up via the project's `.ruby-version` file:

```bash
rbenv global 4.0.6
```

Verify that the active Ruby version matches:

```bash
ruby -v
which ruby
```
*(The output should point to `~/.rbenv/shims/ruby`)*.

---

## 4. Installing Bundler & Gems

Install `bundler` for your new Ruby version:

```bash
gem install bundler
```

Navigate into your `hroot` directory and install project dependencies:

```bash
cd ~/HROOT/hroot
bundle install
```
