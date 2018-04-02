const Token = artifacts.require('./Token.sol');

contract('Token Integration', accounts => {
	let contract;

	const owner = accounts[0];

	before(async () => {
		contract = await Token.deployed();
	});

	it('should pass if a contract is deployed', async function() {
		const name = await contract.name.call();
		assert.strictEqual(name, 'Testy');
	});

	it('should pass if the initial token balance is 1 million', async function() {
		const totalSupply = await contract.totalSupply.call();
		assert.strictEqual(totalSupply.toString(), '1000000');
	});

	it('should [transfer] tokens', async function() {
		const tokenWei = 1000;

		await contract.transfer(accounts[1], tokenWei);

		const ownerBalanceAfter = await contract.balanceOf.call(owner);
		const recipientBalanceAfter = await contract.balanceOf.call(accounts[1]);

		assert.strictEqual(ownerBalanceAfter.toString(), '999000');
		assert.strictEqual(recipientBalanceAfter.toString(), '1000');
	});

	it('should not [transfer] tokens with insufficient funds', async function() {
		const tokenWei = 10000;

		try {
			await contract.transfer(accounts[2], tokenWei, { from: accounts[2] });
		} catch (err) {
			assert.strictEqual(
				err.message,
				'VM Exception while processing transaction: revert'
			);
		}
	});

	it('should [burn] tokens', async function() {
		const tokenWei = 1000;

		await contract.burn(tokenWei);

		const totalSupply = await contract.totalSupply.call();
		assert.strictEqual(totalSupply.toString(), '999000');
	});

	it('should [burnFrom] tokens from an account', async function() {
		const spender = owner;
		const approver = accounts[3];

		const tokenWei = 1000;
		await contract.transfer(approver, tokenWei);
		await contract.approve(spender, tokenWei, { from: approver });
		await contract.burnFrom(approver, tokenWei, { from: spender });

		const recipientBalanceAfter = await contract.balanceOf.call(accounts[3]);
		assert.strictEqual(recipientBalanceAfter.toString(), '0');
	});

	it('should not [burnFrom] tokens from an account', async function() {
		const spender = owner;
		const approver = accounts[3];

		const tokenWei = 1000;
		await contract.transfer(approver, tokenWei);

		try {
			await contract.burnFrom(approver, tokenWei, { from: spender });
		} catch (err) {
			assert.strictEqual(
				err.message,
				'VM Exception while processing transaction: revert'
			);
		}
	});
});
