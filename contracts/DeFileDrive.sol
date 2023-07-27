// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DeFileDrive {
    
    struct FileInfo {
        string fileName;
        string fileDescription;
        string fileCid;
    }

    mapping(address => string[]) usersGroupMap;

    // mapping groupId to user's address
    mapping(string => address[]) groupAddressMap;

    // mapping groupId -> file info
    mapping(string => FileInfo[]) groupIdFileMap;

    function cmpString(string memory a, string memory b) internal pure returns(bool){
       return (keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)));
    }

    function arrayStringIncludes(string[] memory array, string memory item) internal pure returns(bool){
        bool isPresent;
        for(uint i=0;i<array.length; i++){
            if(cmpString(array[i], item)){
                isPresent = true;
                break;
            }
        }
        return isPresent;
    }

    function createGroup(string memory groupId) public {
        require(groupAddressMap[groupId].length == 0, "Group Id already Exists");
        
        address senderAddress = msg.sender;
        groupAddressMap[groupId].push(senderAddress);
        string[] memory currentGroups = usersGroupMap[senderAddress];
        if(currentGroups.length == 0){
            usersGroupMap[senderAddress].push(groupId);
        } else {
            bool isAlreadyPresent;
            for(uint i=0;i<currentGroups.length;i++){
                if(cmpString(currentGroups[i],groupId)){
                    isAlreadyPresent = true;
                }
            }
            if(!isAlreadyPresent){
                usersGroupMap[senderAddress].push(groupId);
            }
        }
    }

    function addUser(string memory groupId, address user2) public {
        require(user2 != msg.sender, "You cannot add youself to an existing group.");
        require(arrayStringIncludes(usersGroupMap[msg.sender], groupId), "You cannot add user to a group of which you are not a part of");

        if(groupAddressMap[groupId].length == 0){
            createGroup(groupId);
        }

        string[] memory user2Groups = usersGroupMap[user2];
        if(user2Groups.length == 0){
            usersGroupMap[user2].push(groupId);
        } else {
            bool isAlreadyPresent;
            for(uint i=0;i<user2Groups.length;i++){
                if(cmpString(user2Groups[i],groupId)){
                    isAlreadyPresent = true;
                }
            }
            if(!isAlreadyPresent){
                usersGroupMap[user2].push(groupId);
            }
        }
        
        address[] memory addressForGroupId = groupAddressMap[groupId];
        bool isAlreadyPresent2;
        for(uint i=0;i<addressForGroupId.length;i++){
            if(addressForGroupId[i] == user2){
                isAlreadyPresent2 = true;
            }
        }
        if(!isAlreadyPresent2){
            groupAddressMap[groupId].push(user2);
        }
    }

    function getMyGroups() public view returns(string[] memory){
        address user = msg.sender;
        return usersGroupMap[user];
    }

    function addFileToGroup(string memory groupId, FileInfo memory fileInfo) public {
        require(arrayStringIncludes(usersGroupMap[msg.sender], groupId), "You cannot add user to a group of which you are not a part of");
        bool isFilePresent;
        for(uint i = 0;i < groupIdFileMap[groupId].length;i++ ){
            if(cmpString(groupIdFileMap[groupId][i].fileCid, fileInfo.fileCid)){
                isFilePresent = true;
            }
        }
        require(isFilePresent == false, "Uploaded file already exists");
        groupIdFileMap[groupId].push(fileInfo);
    }

    function getMyFilesByGroupId(string memory groupId) public view returns(FileInfo[] memory) {
        require(arrayStringIncludes(usersGroupMap[msg.sender], groupId), "You cannot add user to a group of which you are not a part of");
        string[] memory userGroups = usersGroupMap[msg.sender];
        FileInfo[] memory myFiles;

        for(uint i=0; i<userGroups.length;i++){
            if(cmpString(userGroups[i], groupId)){
                myFiles = groupIdFileMap[groupId];
            }
        }
        return myFiles;
    }

}