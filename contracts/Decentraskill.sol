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
        address wallet_address;
        bool is_employed;
        bool is_manager;
        uint256 num_skills;
        uint256 skills;
        uint256 work_experience;
    }

    struct experience {
        string starting_date;
        string ending_date;
        string role;
        bool currently_working;
        uint256 company_id;
        bool is_approved;
    }

    // function sign_up() {

    // }
}