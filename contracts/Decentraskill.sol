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

    constructor() {
        user storage dummy_user = employees.push();
        dummy_user.name = "dummy";
        dummy_user.wallet_address = msg.sender;
        dummy_user.id = 0;
        dummy_user.user_skills = new uint256[](0);
        dummy_user.work_experience = new uint256[](0);
    }

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
        bool verified;
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
    function sign_up(string memory email, string memory name, string memory acc_type) public {
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
    function login(string memory email) public view returns(string memory) {
        require(msg.sender == email_to_address[email], 'Error: Incorrect ');
        return is_company[msg.sender] ? "company" : "user";
    }

    // Update wallet  address
    function update_wallet_address(string memory email, address new_address) external {
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

    // Add experience
    function add_experience(uint256 user_id,
        string memory role,
        string memory starting_date,
        string memory ending_date,
        uint256 company_id) 
        public verifiedUser(user_id) {
        experience storage new_experience = experiences.push();
        new_experience.company_id = company_id;
        new_experience.is_approved = false;
        new_experience.starting_date = starting_date;
        new_experience.ending_date = ending_date;
        new_experience.role = role;
        employees[user_id].work_experience.push(experiences.length - 1);
        companies[company_id].requested_employees.push(experiences.length - 1);
    }

    // Approve experience
    function approve_experience(
        uint256 experience_id,
        uint256 company_id
    ) public {
        require(
        (is_company[msg.sender] &&
        companies[address_to_id[msg.sender]].id == experiences[experience_id].company_id) ||
        (employees[address_to_id[msg.sender]].is_manager &&
        employees[address_to_id[msg.sender]].company_id == experiences[experience_id].company_id), "Error: Approver should be the company or manager"
        );

        uint256 i;
        experiences[experience_id].is_approved = true;

        // Remove item from Requested
        for (i = 0; i < companies[company_id].requested_employees.length; i++) {
            if (companies[company_id].requested_employees[i] == experience_id) {
                companies[company_id].requested_employees[i] = 0;
                break;
            }
        }

        // Add item in Approved
        for (i = 0; i < companies[company_id].current_employees.length; i++) {
            if (companies[company_id].current_employees[i] == 0) {
                companies[company_id].requested_employees[i] = experience_id;
                break;
            }
        }


        if (i == companies[company_id].current_employees.length)
        companies[company_id].current_employees.push(experience_id);
    }

    // Approve manager
    function approve_manager(uint256 employee_id) public {
		require(is_company[msg.sender], "error: sender not a company account");
        require(
            employees[employee_id].company_id == address_to_id[msg.sender],
            "error: user not of the same company"
        );
        require(
            !(employees[employee_id].is_manager),
            "error: user is already a manager"
        );
        employees[employee_id].is_manager = true;
    }

    // Add skill
    function add_skill(uint256 userid, string memory skill_name) public verifiedUser(userid) {
        skill storage new_skill = skills.push();
        employees[userid].user_skills.push(skills.length - 1);
        new_skill.name = skill_name;
        new_skill.verified = false;
        new_skill.skill_certifications = new uint256[](0);
        new_skill.skill_endorsements = new uint256[](0);
    }

    // Add certification
    function add_certification(
        uint256 user_id,
        string memory url,
        string memory issue_date,
        string memory valid_till,
        string memory name,
        string memory issuer,
        uint256 linked_skill_id
    ) public verifiedUser(user_id) {
        certificate storage new_certificate = certifications.push();
        new_certificate.url = url;
        new_certificate.issue_date = issue_date;
        new_certificate.valid_till = valid_till;
        new_certificate.name = name;
        new_certificate.id = certifications.length - 1;
        new_certificate.issuer = issuer;
        skills[linked_skill_id].skill_certifications.push(new_certificate.id);
    }

    // Endorse skill
    function endorse_skill(
        uint256 user_id,
        uint256 skill_id,
        string memory endorsing_date,
        string memory comment
    ) public {
        endorsment storage new_endorsemnt = endorsments.push();
        new_endorsemnt.endorser_id = address_to_id[msg.sender];
        new_endorsemnt.comment = comment;
        new_endorsemnt.date = endorsing_date;
        skills[skill_id].skill_endorsements.push(endorsments.length - 1);
        if (employees[address_to_id[msg.sender]].is_manager) {
            if (
                employees[address_to_id[msg.sender]].company_id ==
                employees[user_id].company_id
            ) {
                skills[skill_id].verified = true;
            }
        }
    }
}