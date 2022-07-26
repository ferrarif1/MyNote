# Project Editor

You can use projects to manage the creation and testing of a dapp. The project will contain data related to both backend and frontend as well as the data related to your scenarios \(blockchain interaction\) for debugging and testing. The related files will be created and saved automatically in the project directory.

## Creating a new project

The development of a dapp start with the creation of a new project. Create a new project in the “edit” menu. Enter the project name, e.g. “Ratings” and select a path for the project file.

## Editing backend contract file

By default, a new project contains a contract “Contract” for backend development on the blockchain using the Solidity language and the “index.html” for the frontend. Check the Solidity tutorial for references.

Edit the empty default contract “Contract”, e.g.

```text
contract Rating {
        function setRating(bytes32 _key, uint256 _value) {
                ratings[_key] = _value;
        }
        mapping (bytes32 => uint256) public ratings;
}
```

Check the Solidity tutorial for help getting started with the solidity programming language.

Save changes

### Editing frontend html files

Select default index.html file and enter the following code

Then it is possible to add many contract files as well as many HTML, JavaScript, css files

