// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Decentraskill {
    // Data declarations
    company[] public companies;
    user[] public employees;
    certificate[] public certifications;
    endorsment[] public endorsments;
    skill[] public skills;
    experience[] public experiences;

    // Mappings
    mapping(string => address) public email_to_address;
    mapping(address => uint256) public address_to_id;
    mapping(address => bool) public is_company;

    // Structure Declarations
    struct company {
        uint256 id;
        string name;
        address wallet_address;
        uint256[] current_employees;
        uint256[] previous_employees;
        uint256[] requested_employees;
    }

    struct user {
        uint256 id;
        uint256 company_id;
        string name;
        address wallet_address;
        bool is_employed;
        bool is_manager;
        uint256 num_skills;
        uint256[] user_skills;
        uint256[] work_experience;
    }

    struct experience {
        string starting_date;
        string ending_date;
        string role;
        bool currently_working;
        uint256 company_id;
        bool is_approved;
    }

    struct certificate {
        uint256 id;
        string url;
        string issue_date;
        string valid_till;
        string name;
        string issuer;
    }

    struct endorsment {
        uint256 endorser_id;
        string date;
        string comment;
    }

    struct skill {
        uint256 id;
        string name;
        bool isVerified;
        uint256[] skill_certifications;
        uint256[] skill_endorsements;
    }

    // Compare the hash
    function memcmp(bytes memory a, bytes memory b) internal pure returns(bool) {
        return (a.length == b.length) && (keccak256(a) == keccak256(b));
    }

    // Compare the strings
    function strcmp(string memory a, string memory b) internal pure returns(bool) { 
        return memcmp(bytes(a), bytes(b));
    }

    // Signup user
    function sign_up(string calldata email, string calldata name, string calldata acc_type) public {
        require(email_to_address[email] == address(0), 'Error: user already exists');

        email_to_address[email] = msg.sender;

        if(strcmp(acc_type, 'user')) {
            user storage new_user = employees.push();
            new_user.id = employees.length - 1;
            address_to_id[msg.sender] = new_user.id;
            new_user.name = name;
            new_user.wallet_address = msg.sender;
            new_user.user_skills = new uint256[](0);
            new_user.work_experience = new uint256[](0);
        } else if(strcmp(acc_type, 'company')) {
            company storage new_company = companies.push();
            new_company.name = name;
            new_company.id = companies.length - 1;
            new_company.wallet_address = msg.sender;
            new_company.current_employees = new uint256[](0);
            new_company.previous_employees = new uint256[](0);
            address_to_id[msg.sender] = new_company.id;
            is_company[msg.sender] = true;
        }
    }

    // Login user
    function login(string calldata email) public view returns(string memory) {
        require(msg.sender == email_to_address[email], 'Error: Incorrect ');
        return is_company[msg.sender] ? "company" : "user";
    }

    // Update wallet  address
    function update_wallet_address(string calldata email, address new_address) external {
        require(email_to_address[email] == msg.sender, "Error: Function called from incorrect wallet address");

        email_to_address[email] = new_address;
        uint256 id = address_to_id[msg.sender];
        address_to_id[msg.sender] = 0;
        address_to_id[new_address] = id;
    }

    // Check if verified user
    modifier verifiedUser(uint256 user_id) {
        require(user_id == address_to_id[msg.sender]);
        _;
    }
}