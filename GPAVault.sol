// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title GPAVault
 * @notice Stores student identity and GPA record hashes on-chain.
 *         Students register once (wallet → name, matric, institution),
 *         then store SHA-256 hashes of their local GPA payload.
 *         Anyone can verify a (address, hash) pair trustlessly.
 */
contract GPAVault {

    // ── Structs ──────────────────────────────────────────────────────────
    struct Student {
        string  name;
        string  matricNo;
        string  institution;
        uint256 registeredAt;
        bool    exists;
    }

    struct Record {
        bytes32 dataHash;
        uint256 timestamp;
        string  label;      // e.g. "CGPA: 4.72 (120 units, First Class, 5.0 scale)"
    }

    // ── Storage ──────────────────────────────────────────────────────────
    mapping(address => Student)  public students;
    mapping(address => Record[]) private _records;

    // ── Events ───────────────────────────────────────────────────────────
    event Registered(address indexed student, string name, string matricNo, string institution);
    event RecordStored(address indexed student, bytes32 indexed dataHash, string label, uint256 timestamp);

    // ── Registration ─────────────────────────────────────────────────────
    /**
     * @notice Register or update student identity.
     * @dev    Can be called again to update profile fields.
     */
    function register(
        string calldata name,
        string calldata matricNo,
        string calldata institution
    ) external {
        require(bytes(name).length > 0,        "Name required");
        require(bytes(matricNo).length > 0,    "Matric number required");
        require(bytes(institution).length > 0, "Institution required");

        students[msg.sender] = Student({
            name:         name,
            matricNo:     matricNo,
            institution:  institution,
            registeredAt: block.timestamp,
            exists:       true
        });

        emit Registered(msg.sender, name, matricNo, institution);
    }

    // ── GPA Record Storage ───────────────────────────────────────────────
    /**
     * @notice Store a SHA-256 hash of the student's local GPA payload.
     * @dev    Must be registered first.
     * @param  dataHash  32-byte SHA-256 hash of the JSON payload.
     * @param  label     Human-readable summary (CGPA, units, classification).
     */
    function storeRecord(bytes32 dataHash, string calldata label) external {
        require(students[msg.sender].exists, "Register first");
        require(dataHash != bytes32(0),      "Invalid hash");

        _records[msg.sender].push(Record({
            dataHash:  dataHash,
            timestamp: block.timestamp,
            label:     label
        }));

        emit RecordStored(msg.sender, dataHash, label, block.timestamp);
    }

    // ── Read Helpers ─────────────────────────────────────────────────────
    function getStudent(address student)
        external view
        returns (string memory name, string memory matricNo, string memory institution, uint256 registeredAt)
    {
        Student storage s = students[student];
        require(s.exists, "Not registered");
        return (s.name, s.matricNo, s.institution, s.registeredAt);
    }

    function getRecordCount(address student) external view returns (uint256) {
        return _records[student].length;
    }

    function getRecord(address student, uint256 index)
        external view
        returns (bytes32 dataHash, uint256 timestamp, string memory label)
    {
        require(index < _records[student].length, "Out of range");
        Record storage r = _records[student][index];
        return (r.dataHash, r.timestamp, r.label);
    }

    function getLatestRecord(address student)
        external view
        returns (bytes32 dataHash, uint256 timestamp, string memory label)
    {
        uint256 count = _records[student].length;
        require(count > 0, "No records");
        Record storage r = _records[student][count - 1];
        return (r.dataHash, r.timestamp, r.label);
    }

    /**
     * @notice Verify whether a (student, hash) pair was ever stored.
     */
    function verifyRecord(address student, bytes32 dataHash)
        external view
        returns (bool found, uint256 timestamp)
    {
        Record[] storage recs = _records[student];
        for (uint256 i = recs.length; i > 0; i--) {
            if (recs[i - 1].dataHash == dataHash) {
                return (true, recs[i - 1].timestamp);
            }
        }
        return (false, 0);
    }

    /**
     * @notice Lookup student profile by matric number (linear scan — off-chain indexing preferred).
     */
    function isRegistered(address student) external view returns (bool) {
        return students[student].exists;
    }
}
