/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public without sharing class UUID {

    public static Boolean isEmpty(String uuid) {
        return String.isBlank(uuid) || uuid == '00000000-0000-0000-0000-000000000000';
    }

    public static Boolean isValid(String uuid) {
        if(isEmpty(uuid)) return false;

        String uuidRegEx = '[A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-F0-9]{12}';
        Pattern uuidPattern = Pattern.compile(uuidRegEx);
        Matcher uuidMatcher = uuidPattern.matcher(uuid.toUpperCase());

        return uuidMatcher.matches();
    }

    public String getValue() {
        Blob generatedBlob = Crypto.GenerateAESKey(128);
        String hex = EncodingUtil.ConvertTohex(generatedBlob);
        String uuid = hex.substring(0, 8)
            + '-' + hex.substring(8, 12)
            + '-' + hex.substring(12, 16)
            + '-' + hex.substring(16, 20)
            + '-' + hex.substring(20);

        return uuid.toUpperCase();
    }

}