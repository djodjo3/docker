#!/bin/bash

php_version_default="5.6-apache"

generate_image()
{
    echo "Generate Dockerfile for PrestaShop $version - PHP $php_version"

    if [ "${php_version}x" = "x" ]; then
        folder="${version}";
        php_version=$php_version_default
    elif [ $version = "nightly" ]; then
        folder="${version}-$php_version";
    else
        folder="${version:0:3}-$php_version";
    fi

    mkdir -p images/$folder/

    if [ $version = "nightly" ]; then
        sed  '
                s/{PS_VERSION}/'"$version"'/;
                s/{PHP_VERSION}/'"$php_version"'/
            ' Dockerfile-nightly.model > images/$folder/Dockerfile
    else
        sed  '
                s/{PS_VERSION}/'"$version"'/;
                s/{PHP_VERSION}/'"$php_version"'/;
                s/{PS_URL}/'"https:\/\/www.prestashop.com\/download\/old\/prestashop_$version.zip"'/
            ' Dockerfile.model > images/$folder/Dockerfile
    fi
}

if [ -z "$1" ]; then
    ps_versions_file="versions.txt";
else
    ps_versions_file="$1";
fi

# Generate images for all PrestaShop versions from 1.4 on PHP 5.6
echo "Reading versions in $ps_versions_file ..."
while read version; do
    php_version=""
    generate_image
done <$ps_versions_file

# Generate images for each major version of PrestaShop on different PHP environment
for php_version in "5.6-apache" "7.0-apache" "7.1-apache" "7.2-apache" "5.6-fpm" "7.0-fpm" "7.1-fpm" "7.2-fpm"
do

    for major_version in "15" "16" "17" "nightly"
    do
        version=$(grep "." versions$major_version.txt | tail -1)
        generate_image
    done

done
