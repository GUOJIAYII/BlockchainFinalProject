pragma solidity 0.8.0;

contract SupplyChain{

    event Sign(address payerAddress, address payeeAddress, uint amount, uint deadline);
    event Transfer(address senderAddress, uint tarInvoiceIndex, address receiverAddress, uint amount);
    event Finance(address borrowerAddress, uint tarInvoiceIndex, address bankAddress, uint amount);
    event Settle(address payerAddress, address payeeAddress, uint amount);

    struct Company{
        uint id;
        address cAddress;
        bytes32 cName;
        bytes32 password;
        bool isBank;
    }

    struct Invoice{
        address payerAddress;
        address payeeAddress;
        uint amount;
        uint deadline;
    }

    uint cNum;
    mapping (bytes32 => address) public cAddressName;
    mapping (uint => address) public cAddressInt;
    mapping (address => Company) public companys;
    mapping (address => Invoice[]) public invoices;

    
    constructor() 
    public 
    {
        cNum = 0;
    }

/* 
    function getAddress()
    public
    returns (address addr)
    {
        addr = msg.sender;
    }
*/    

    function stringToBytes32(string memory source)
    public 
    pure 
    returns (bytes32 result) 
    {
        bytes memory temp = bytes(source);
        if (temp.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }

    function register(address cAddress, string memory cName, string memory password, bool isBank)
    public
    returns(bool)
    {
        bytes32 cNamebytes = stringToBytes32(cName);
        for(uint i = 0; i < cNum; i++){
            //保证公司没有重名
            require(cNamebytes != companys[cAddressInt[i]].cName, "There exists a client who has the same username.");
            //保证公司没有重地址
            require(cAddress != companys[cAddressInt[i]].cAddress, "There exists a client who has the same address.");
        }
        cAddressName[cNamebytes] = cAddress;
        cAddressInt[cNum] = cAddress;
        companys[cAddress] = Company(cNum++, cAddress, cNamebytes, stringToBytes32(password), isBank);
        return true;
    }

    function checkPassword(address cAddress, string memory password)
    public
    view
    returns(bool)
    {
        return (companys[cAddress].password == stringToBytes32(password));
    }

    function signInvoice(string memory payerName, string memory password, string memory payeeName, uint amount, uint deadline)
    public
    returns(bool)
    {
        address payerAddress = cAddressName[stringToBytes32(payerName)];
        //保证存在公司
        require(payerAddress != 0x0000000000000000000000000000000000000000, "No such payer.");
        //保证公司地址和密码匹配
        require(checkPassword(payerAddress, password) == true, "Wrong password.");
        address payeeAddress = cAddressName[stringToBytes32(payeeName)];
        //保证存在公司
        require(payeeAddress != 0x0000000000000000000000000000000000000000, "No such payee.");
        invoices[payeeAddress].push(Invoice(payerAddress, payeeAddress, amount, deadline));
        emit Sign(payerAddress, payeeAddress, amount, deadline);
        return true;
    }

    function transferInvoice(string memory senderName, string memory password, uint tarInvoiceIndex, string memory receiverName, uint amount)
    public
    returns(bool)
    {
        address senderAddress = cAddressName[stringToBytes32(senderName)];
        //保证存在公司
        require(senderAddress != 0x0000000000000000000000000000000000000000, "No such sender.");
        //保证公司地址和密码匹配
        require(checkPassword(senderAddress, password) == true, "Wrong password.");
        //保证存在单据
        require(getInvoiceNum(senderName) > tarInvoiceIndex, "No such invoice.");
        address receiverAddress = cAddressName[stringToBytes32(receiverName)];
        //保证存在公司
        require(receiverAddress != 0x0000000000000000000000000000000000000000, "No such receiver.");
        Invoice memory tar = invoices[senderAddress][tarInvoiceIndex];
        //保证单据的金额大于等于转账金额
        require(tar.amount >= amount, "Transfer amount should less than or equal to the invoice amount.");
        invoices[receiverAddress].push(Invoice(tar.payerAddress, receiverAddress, amount, tar.deadline));
        invoices[senderAddress][tarInvoiceIndex].amount -= amount;
        emit Transfer(senderAddress, tarInvoiceIndex, receiverAddress, amount);
        return true;
    }

    function finance(string memory borrowerName, string memory password, uint tarInvoiceIndex, string memory bankName, uint amount)
    public
    returns(bool)
    {
        address borrowerAddress = cAddressName[stringToBytes32(borrowerName)];
        //保证存在公司
        require(borrowerAddress != 0x0000000000000000000000000000000000000000, "No such borrower.");
        //保证公司地址和密码匹配
        require(checkPassword(borrowerAddress, password) == true, "Wrong password.");
        address bankAddress = cAddressName[stringToBytes32(bankName)];
        //保证存在公司
        require(bankAddress != 0x0000000000000000000000000000000000000000, "No such bank.");
        //保证贷款对象是银行
        require(companys[bankAddress].isBank == true, "It is not a bank.");
        //保证存在单据
        require(getInvoiceNum(borrowerName) > tarInvoiceIndex, "No such invoice.");
        Invoice memory tar = invoices[borrowerAddress][tarInvoiceIndex];
        //保证单据的金额大于等于贷款金额
        require(tar.amount >= amount, "Finance amount should less than or equal to the invoice amount.");
        invoices[bankAddress].push(Invoice(tar.payerAddress, bankAddress, amount, tar.deadline));
        invoices[borrowerAddress][tarInvoiceIndex].amount -= amount;
        emit Finance(borrowerAddress, tarInvoiceIndex, bankAddress, amount);
        return true;
    }

    //没有偿还某一个账单的选项，因为所有衍生账单还款时限一样，所以对于还款这个操作没有区分的必要
    function settle(string memory payerName, string memory password, uint amount) 
    public
    returns(bool)
    {
        address payerAddress = cAddressName[stringToBytes32(payerName)];
        //保证存在公司
        require(payerAddress != 0x0000000000000000000000000000000000000000, "No such payer.");
        //保证公司地址和密码匹配
        require(checkPassword(payerAddress, password) == true, "Wrong password.");
        //遍历公司
        for(uint i = 0; i < cNum; i++){
            address a = cAddressInt[i];
            //遍历公司的单据
            for(uint j = 0; j < invoices[a].length; j++){
                //还款单据要求payerAddress和还款公司地址一致，amount和deadline大于0
                if(invoices[a][j].payerAddress == payerAddress && invoices[a][j].amount > 0 && invoices[a][j].deadline > 0){
                    if(invoices[a][j].amount >= amount){
                        invoices[a][j].amount -= amount;
                        emit Settle(payerAddress, a, amount);
                    }
                    else{
                        uint temp = invoices[a][j].amount;
                        invoices[a][j].amount = 0;
                        emit Settle(payerAddress, a, temp);
                        settle(payerName, password, amount - temp);
                    }
                }
            }
        }
        return true;
    }

/*

    function showInvoices1(string cName)

    public

    view

    returns(address[] memory payerAddress, address[] memory payeeAddress, uint[] memory amount, uint[] memory deadline)

    {

        address cAddress = cAddressName[stringToBytes32(cName)];

        

        //待收款的invoice

        uint k = 0;

        for(uint i = 0; i < invoices[cAddress].length; i++){

            if(invoices[cAddress][i].amount > 0){

                Invoice memory t = invoices[cAddress][i];

                payerAddress[k] = t.payerAddress;

                payeeAddress[k] = t.payeeAddress;

                amount[k] = t.amount;

                deadline[k++] = t.deadline;

            }

        }

    }



    function showInvoices2(string cName)

    public

    view

    returns(address[] memory payerAddress, address[] memory payeeAddress, uint[] memory amount, uint[] memory deadline)

    {

        address cAddress = cAddressName[stringToBytes32(cName)];

        //payerAddress.push(0);

        

        //待还款的invoice

        uint k = 0;

        for(uint i = 0; i < cNum; i++){

            address a = cAddressInt[i];

            for(uint j = 0; j < invoices[a].length; j++){

                if(invoices[a][j].payerAddress == cAddress && invoices[a][j].amount > 0){

                    Invoice memory t = invoices[a][j];

                    payerAddress[k] = t.payerAddress;

                    payeeAddress[k] = t.payeeAddress;

                    amount[k] = t.amount;

                    deadline[k++] = t.deadline;

                }

            }

        }

    }

*/

    function getInvoiceNum(string memory cName)
    public
    view
    returns(uint invoiceNumber)
    {
        address cAddress = cAddressName[stringToBytes32(cName)];
        invoiceNumber = invoices[cAddress].length;
    }

    function getInvoice(string memory cName, uint index)
    public
    view
    returns(address payerAddress, address payeeAddress, uint amount, uint deadline)
    {
        require(getInvoiceNum(cName) > index, "The invoice doesn't exist.");
        address cAddress = cAddressName[stringToBytes32(cName)]; 
        payerAddress = invoices[cAddress][index].payerAddress;
        payeeAddress = invoices[cAddress][index].payeeAddress;
        amount = invoices[cAddress][index].amount;
        deadline = invoices[cAddress][index].deadline;
    }
}