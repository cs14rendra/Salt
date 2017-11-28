# Salt
Salt projects is made to show the integration of Amazon s3 and mazon cognito in iOS.

## Installation

#### Amazon Server
Amzon account setup is more complicated than iOS Code, here is the headlines to help reader to setup amazon account.
- login in amazon and create a identity pool
- Update policies to Aws S3 using amazon ARN
- Create a facebook App on facebook.com
- Enable facebook login as identity Provider
- Create a bucket , make sure to choose same region for identity pool and bucket (for this project)
- Update a policy for your bucket using ARN. (in this project we have 1 private and 2 public bucket)

### Client
- Setup info.plist for facebook
- Replace poolID and region with your own
- To upload there is a default 'my.txt' file.
- To download copy url from bucket manually or get url after successful upload

## Tasks

- [x] Amazon Idntity Provider Setup
- [x] Amazon Bucket Setup
- [x] FaceBook Setup as ID Provider
- [x] Upload a default file 'my.txt' in private or public bucket
- [x] download files if exist for given url

## Requirements
- ios 11.0+
- xcode 9.0+

## Usefull links
- http://docs.aws.amazon.com/aws-mobile/latest/developerguide/getting-started.html
- http://docs.aws.amazon.com/cognito/latest/developerguide/what-is-amazon-cognito.html
- https://developers.facebook.com/docs/ios/getting-started/

## License
Salt is available under the MIT license. See the LICENSE file for more info.


