purebmi
=======

simple body mass index calculator built with purescript &
purescript-thermite (react wrapper).

compare: http://en.wikipedia.org/wiki/Body_mass_index


to build during hacking / for preview run:
    pulp browserify --to index.js --watch

to update gh-pages branch:
    pulp dep install
    pulp browserify --to index.js
    git add -f index.html index.js bower_components
