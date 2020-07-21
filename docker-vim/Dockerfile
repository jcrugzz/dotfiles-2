FROM alpine:edge

RUN apk update \
    && apk --no-cache add curl vim fzf bash git ripgrep

RUN mkdir -p /root/.vim 

COPY vimrc-portable /root/.vimrc
COPY run-vim /usr/local/bin/run-vim

ENV TERM=xterm-256color

RUN  curl -fLo /root/.vim/autoload/plug.vim  --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
     && vim +PlugInstall +qa \
     && mkdir /workspace 

WORKDIR /workspace

ENTRYPOINT ["sh", "/usr/local/bin/run-vim"]
