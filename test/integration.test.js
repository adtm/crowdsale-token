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
});
