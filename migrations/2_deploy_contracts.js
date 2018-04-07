const Token = artifacts.require('Token');
const Crowdsale = artifacts.require('Crowdsale');

module.exports = deployer => {
	deployer.deploy(Token).then(function(instance) {
		return deployer.deploy(
			Crowdsale,
			10000,
			1,
			1522869325,
			1570497200,
			Token.address
		);
	});
};
