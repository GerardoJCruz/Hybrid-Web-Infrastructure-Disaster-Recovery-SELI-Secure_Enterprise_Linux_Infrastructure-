const { src, dest, watch, series} = require('gulp');

//Compile CSS 
const sass = require('gulp-sass')(require('sass'));
const purgecss = require('gulp-purgecss');
const rename = require('gulp-rename');

//Images 
const imagemin = require('gulp-imagemin');

function css(done){
    src('src/scss/app.scss') //Identify the main file
        .pipe(sass()) //Compile SASS
        .pipe(dest('build/css')) //Export and save it in this ubication
    done();
}

function cssbuild(done){
    src('build/css/app.css')
        .pipe(rename({
            suffix: '.min'
        }))
        .pipe(purgecss({
            content: ['index.html', 'base.html', 'about_us.html', 'process.html', 'menu.html', 'gallery.html', 'contact.html']
        }))
        .pipe(dest('build/css'))
    done();
}

function dev(done){
    watch('src/scss/**/*.scss', css);
    watch('src/img/**/*', )
    done();
}

function images(done){
    src('src/img/**/*')
        .pipe(imagemin({optimizationLevel: 3}))
        .pipe(dest('build/img'))
    done();
}

exports.css = css;
exports.dev = dev;
exports.imagemin = imagemin;
exports.default = series(images, css, dev);
exports.build = series(cssbuild);