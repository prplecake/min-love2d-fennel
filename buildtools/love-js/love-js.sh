help="love-js.sh: \n\
    A tool for asembling love.js projects without relying on npm / node. \n\
    For the full project please see https://github.com/Davidobot/love.js \n\
\n\
usage: \n\
    ./love-js.sh [directory-name] [project-name] [version] \n\
\n\
eg: \n\
    ./love-js.sh ../../releases/ project 0.1.0 \n\
    ./tools/love-js/love-js.sh releases project 0.1.0\n\
\n\
"

if [ "$#" -lt  "3" ]
  then
      echo "ERROR! love-js.sh expects three arguments."
      echo -e $help
      exit 1
fi

release_dir=$1
name=$2
version=$3

## confirm that $release_dir/$name-$version.love exists
if [ ! -f $release_dir/$name-$version.love ]; then
    echo "love file not found!"
    echo $release_dir/$name-$version.love
    exit 1
fi

release="compat"
canvas_colour="197, 204, 184"
page_colour=$canvas_colour
text_colour="102, 96, 146"
initial_memory=$(du -b $release_dir/$name-$version.love | awk '{print $1}')
title=$(echo $name-$version | sed -r 's/\<./\U&/g' | sed -r 's/-/\ /g')

# echo $title " " $canvas_colour " " $text_colour " " $initial_memory

call_dir=$(pwd)
cd "$(dirname "$0")"

mkdir -p $name-$version && mkdir -p $name-$version/theme

cat src/index.html | \
    sed "s/{{title}}/${title}/g" | \
    sed "s/{{initial-memory}}/${initial_memory}/g" | \
    sed "s/{{canvas-colour}}/${canvas_colour}/g" | \
    sed "s/{{text-colour}}/${text_colour}/g" > \
    $name-$version/index.html

cat src/love.css | \
    sed "s/{{page-colour}}/${page_colour}/g" > \
        $name-$version/theme/love.css

cp src/consolewrapper.js $name-$version
cp src/game.js $name-$version
cp $release_dir/$name-$version.love $name-$version/game.data
cp src/$release/love.js $name-$version
cp src/$release/love.wasm $name-$version
cp src/release/love.worker.js $name-$version
zip -r -q tmp $name-$version
mv tmp.zip $call_dir/$name-$version-web.zip
rm -rf $name-$version
