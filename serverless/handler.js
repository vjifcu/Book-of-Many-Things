var AWS = require('aws-sdk');
var base32 = require('base32')
var s3 = new AWS.S3();

exports.save = function(event, context, callback) {
    //console.log(JSON.stringify(event, null, 2));
    var s3 = new AWS.S3();
    
    s3.getObject({
        Bucket: 'serverless-admin-dev-serverlessdeploymentbucket-4xb659gh8lep/test',
        Key: 'currentIndex'
    }, function(err, data) {
        if (err) {
            console.log(err, err.stack);
        } else {
            var nextIndex = parseInt(data.Body.toString('ascii'))+1
            
            var param = {Bucket: 'serverless-admin-dev-serverlessdeploymentbucket-4xb659gh8lep/test', Key: nextIndex.toString(), Body: event};
            
            console.log("PREPARING TO CREATE NEW SPELL FILE")
            s3.upload(param, function(err, data) {
                if (err) console.log(err, err.stack); // an error occurred
                else console.log(data);           // successful response

                var param2 = {Bucket: 'serverless-admin-dev-serverlessdeploymentbucket-4xb659gh8lep/test', Key: 'currentIndex', Body: nextIndex.toString()};
                console.log("PREPARING TO INCREMENT CURRENTINDEX FILE")
                s3.upload(param2, function(err, data) {
                    if (err) console.log(err, err.stack); // an error occurred
                    else console.log(data);           // successful response

                    console.log("INCREMENTED CURRENTINDEX FILE");
                    callback(null, base32.encode(nextIndex.toString()))
                });
                
                
            });
            
        }
    });
};