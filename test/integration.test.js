const Token = artifacts.require('./Token.sol');

describe('Token Integration', function(accounts) {
	let contract;

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
});
