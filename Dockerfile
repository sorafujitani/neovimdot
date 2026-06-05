# ============================================================
# Stage 1: Download & build tools (not included in final image)
# ============================================================
FROM ubuntu:24.04 AS builder

ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget unzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# lua-language-server
ARG LUA_LS_VERSION=3.13.6
RUN LUA_LS_ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "linux-arm64" || echo "linux-x64") \
    && wget -qO /tmp/lua-ls.tar.gz \
       "https://github.com/LuaLS/lua-language-server/releases/download/${LUA_LS_VERSION}/lua-language-server-${LUA_LS_VERSION}-${LUA_LS_ARCH}.tar.gz" \
    && mkdir -p /opt/lua-language-server \
    && tar xzf /tmp/lua-ls.tar.gz -C /opt/lua-language-server

# stylua
ARG STYLUA_VERSION=2.0.2
RUN STYLUA_ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "linux-aarch64" || echo "linux-x86_64") \
    && wget -qO /tmp/stylua.zip \
       "https://github.com/JohnnyMorganz/StyLua/releases/download/v${STYLUA_VERSION}/stylua-${STYLUA_ARCH}.zip" \
    && unzip /tmp/stylua.zip -d /usr/local/bin/

# lazygit
ARG LAZYGIT_VERSION=0.44.1
RUN LAZYGIT_ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "x86_64") \
    && wget -qO- "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz" \
    | tar xzf - -C /usr/local/bin lazygit

# shfmt
ARG SHFMT_VERSION=3.10.0
RUN SHFMT_ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "amd64") \
    && wget -qO /usr/local/bin/shfmt \
       "https://github.com/mvdan/sh/releases/download/v${SHFMT_VERSION}/shfmt_v${SHFMT_VERSION}_linux_${SHFMT_ARCH}" \
    && chmod +x /usr/local/bin/shfmt

# fzf
ARG FZF_VERSION=0.57.0
RUN FZF_ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "arm64" || echo "amd64") \
    && wget -qO- "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_${FZF_ARCH}.tar.gz" \
    | tar xzf - -C /usr/local/bin

# ============================================================
# Stage 2: Final image
# ============================================================
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    HOME=/root \
    XDG_CONFIG_HOME=/root/.config \
    XDG_DATA_HOME=/root/.local/share \
    XDG_STATE_HOME=/root/.local/state \
    XDG_CACHE_HOME=/root/.cache

# Neovim + Node.js + core tools
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       software-properties-common curl ca-certificates \
    && add-apt-repository -y ppa:neovim-ppa/unstable \
    && apt-get update \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends \
       neovim nodejs git ripgrep fd-find xclip \
       build-essential ca-certificates \
    && ln -sf /usr/bin/fdfind /usr/bin/fd \
    # npm global tools
    && npm install -g --prefer-offline \
       typescript-language-server typescript \
       vscode-langservers-extracted \
       @fsouza/prettierd prettier \
       pnpm tree-sitter-cli \
    # cleanup
    && apt-get purge -y software-properties-common \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /root/.npm/_cacache

# Copy static binaries from builder stage
COPY --from=builder /opt/lua-language-server /opt/lua-language-server
COPY --from=builder /usr/local/bin/stylua    /usr/local/bin/stylua
COPY --from=builder /usr/local/bin/lazygit   /usr/local/bin/lazygit
COPY --from=builder /usr/local/bin/shfmt     /usr/local/bin/shfmt
COPY --from=builder /usr/local/bin/fzf       /usr/local/bin/fzf
RUN ln -sf /opt/lua-language-server/bin/lua-language-server /usr/local/bin/lua-language-server

# Copy Neovim config
COPY . /root/.config/nvim/

# Pre-install plugins
RUN nvim --headless "+Lazy! sync" +qa

# Pre-install Treesitter parsers (lazy: BufReadPost 後に nvim-treesitter が載るためダミーバッファを開いてから install)
RUN touch /tmp/.nvim-ts-init.lua \
    && nvim --headless \
        -c "e /tmp/.nvim-ts-init.lua" \
        -c "lua require('nvim-treesitter').install({'lua','javascript','typescript','tsx','rust','go','ruby','html','css','json','yaml','toml','markdown','bash','vim','vimdoc','python'}):wait()" \
        -c "qa"

WORKDIR /workspace
ENTRYPOINT ["nvim"]
CMD ["."]
