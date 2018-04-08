const Crowdsale = artifacts.require('./Crowdsale.sol');
const Token = artifacts.require('./Token.sol');

contract('Crowdsale [integration] tests', accounts => {
	let crowdsaleContract;
	let tokenContract;

	const owner = accounts[0];

	before(async () => {
		crowdsaleContract = await Crowdsale.deployed();
		tokenContract = await Token.deployed();
	});

	it('should pass if the crowdsale [owner] is same as token [owner]', async function() {
		const crowdsaleOwner = await crowdsaleContract.owner.call();
		assert.strictEqual(crowdsaleOwner, owner);
	});

	it('should increment [amountRaised] when a [buyTokens] is done', async function() {
		const buyer = accounts[1];
		const tokenAmount = 100;

		await Promise.all([
			crowdsaleContract.buyTokens({
				from: buyer,
				value: tokenAmount
			}),
			crowdsaleContract.buyTokens({
				from: buyer,
				value: tokenAmount
			})
		]);

		const buyerTokenAmount = await tokenContract.balanceOf(buyer);
		const amountRaisedAfter = await crowdsaleContract.amountRaised.call();

		assert.strictEqual(buyerTokenAmount.toString(), '100');
		assert.strictEqual(
			amountRaisedAfter.toString(),
			(tokenAmount * 2).toString()
		);
	});
});
