// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "../node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol";
// import "./Structs.sol";
import "./PayrollFactory.sol";

/**
 * The main contract of the app
 */
contract AgorumFactory is PayrollFactory {
  using SafeCast for uint256;

  struct Agorum {
    string name;
    address payable[] agorumCreators;
    Course[] courses;
  }

  // potentially don't need to store courses, just store in decentralized storage
  struct Course {
    string title;
    address payable[] courseCreators;
  }

  // tracker of all agorums, mapping AgorumID to Agorum struct
  mapping (uint => Agorum) public agorums;
  uint public numAgorums = 0;

  /**
   * @dev Checks for message sender is one of the Agorum creators
   * @param agorumCreators array of addresses of the creators
   */
  modifier onlyCreator(address payable[] memory agorumCreators) {
    // loop through agorum's creators until one is found
    bool creator = false;
    uint index = 0;
    while (!creator && index < agorumCreators.length) {
      if (msg.sender == agorumCreators[index]) {
        creator = true;
      }
      index++;
    }

    // if creator is found, execute the function body
    if (creator) {
      _;
    }
  }

  /**
   * @dev Creates a new agorum with given name and array of creators. Adds new Agorum to the mapping tracker.
   * @dev Since an Agorum must be composed of at least one course, a course is also created and pushed to Agorum's courses.
   * @param _name the agorum name
   * @param _creators address of the creators
   */
  function createNewAgorum(string calldata _name, address payable[] calldata _creators, uint _reputationLevel, uint _mentorPaymentRate) public {
    // New Agorum receives ID of corresponding number of Agorums
    uint agorumID = numAgorums++;
    // Assign agorum to mapping, assigning name and creators
    agorums[agorumID].name = _name;
    agorums[agorumID].agorumCreators = _creators;
    // create and add the corresponding course to the Agorum
    addNewCourse(agorumID, _name, _creators);

    // INITIALIZE CROWDFUND & PAYROLL???
    createPayroll(agorumID, _reputationLevel, _mentorPaymentRate);

    emit AgorumCreated(agorumID, _name, _creators);
  }

  /**
   * @dev Adds a new course to an Agorum
   */
  function addNewCourse(uint _agorumID, string calldata _name, address payable[] calldata _courseCreators) public {
    Agorum storage a = agorums[_agorumID];
    a.courses.push(_createNewCourse(_name, _courseCreators));

    emit CourseAdded(_agorumID, _name, _courseCreators);
  }

  /**
   * @dev Add a new course to an Agorum
   * @param _title the course title
   * @param _courseCreators the course creators
   * @return the newly created course
   */
  function _createNewCourse(string calldata _title, address payable[] calldata _courseCreators) pure internal returns (Course memory) {
    Course memory c;
    c.title = _title;
    c.courseCreators = _courseCreators;
    return c;
  }

  /**
   * @dev Retrieves the metadata of an Agorum, ie, name, creators, and courses
   * @dev Does not return Crowdfund or Payroll information
   * @param _agorumID the ID of the Agorum
   * @return the Agorum name, creators, and courses
   */
  function getAgorumMetadata(uint _agorumID) public view returns (string memory, address payable[] memory, Course[] memory) {
    Agorum storage a = agorums[_agorumID];
    return (a.name, a.agorumCreators, a.courses);
  }

  event AgorumCreated(uint agorumID, string name, address payable[] agorumCreators);
  event CourseAdded(uint agorumID, string title, address payable[] courseCreators);
}
