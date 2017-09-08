var AWS = require('aws-sdk');
var s3 = new AWS.S3();

exports.save = function(event, context) {
    //console.log(JSON.stringify(event, null, 2));
    var s3 = new AWS.S3();
    var param = {Bucket: 'serverless-admin-dev-serverlessdeploymentbucket-4xb659gh8lep/test', Key: 'test', Body: 'me me me'};
    console.log("s3");
    s3.upload(param, function(err, data) {
        if (err) console.log(err, err.stack); // an error occurred
        else console.log(data);           // successful response

        console.log('actually done!');
        context.done();
    });

    console.log('done?');
    //context.done();
};