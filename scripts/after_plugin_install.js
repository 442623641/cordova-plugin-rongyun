module.exports = function(context) {

    var fs = context.requireCordovaModule('fs'),
        path = context.requireCordovaModule('path');

    var platformRoot = path.join(context.opts.projectRoot, 'platforms/android');

    var plugins = context.opts.plugins || [];
    // The plugins array will be empty during platform add
    if (plugins.length > 0 && plugins.indexOf('cordova-plugin-rongyun') === -1) {
        return;
    }
    var manifestFile = path.join(platformRoot, 'AndroidManifest.xml');
    if (!fs.existsSync(manifestFile)) {
        manifestFile = path.join(platformRoot, 'app/src/main/AndroidManifest.xml');
    }
    console.log("platformRoot:" + manifestFile);
    if (fs.existsSync(manifestFile)) {

        fs.readFile(manifestFile, 'utf8', function(err, data) {
            if (err) {
                throw new Error('Unable to find AndroidManifest.xml: ' + err);
            }

            var appClass = 'com.rongyun.im.AppContext';

            if (data.indexOf(appClass) == -1) {

                var result = data.replace(/<application/g, '<application android:name="' + appClass + '"');
                var taskTag = 'android:launchMode="singleTop" android:name="MainActivity"'
                if (result.indexOf(taskTag) > -1) {
                    result = result.replace(taskTag, 'android:launchMode="singleTask" android:name="MainActivity"');
                    console.log('android launchMode replace to singleTask');
                }

                fs.writeFile(manifestFile, result, 'utf8', function(err) {
                    if (err) throw new Error('Unable to write into AndroidManifest.xml: ' + err);
                })
                console.log('android application add [android:name="' + appClass + '"]');
            }

        });
    }
};