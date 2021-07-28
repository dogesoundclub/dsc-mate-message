import { expect } from "chai";
import { ethers, network, waffle } from "hardhat";
import DogeSoundClubMateArtifact from "../artifacts/contracts/DogeSoundClubMate.sol/DogeSoundClubMate.json";
import DSCMateMessageArtifact from "../artifacts/contracts/DSCMateMessage.sol/DSCMateMessage.json";
import { DogeSoundClubMate } from "../typechain/DogeSoundClubMate";
import { DSCMateMessage } from "../typechain/DSCMateMessage";

const { deployContract } = waffle;

async function mine(count = 1): Promise<void> {
    expect(count).to.be.gt(0);
    for (let i = 0; i < count; i += 1) {
        await ethers.provider.send("evm_mine", []);
    }
}

describe("DSCMateMessage", () => {
    let mate: DogeSoundClubMate;
    let mateMessage: DSCMateMessage;

    const provider = waffle.provider;
    const [admin, other] = provider.getWallets();

    beforeEach(async () => {
        mate = await deployContract(
            admin,
            DogeSoundClubMateArtifact,
            []
        ) as DogeSoundClubMate;
        mateMessage = await deployContract(
            admin,
            DSCMateMessageArtifact,
            [mate.address]
        ) as DSCMateMessage;
    })

    context("new DSCMateMessage", async () => {
        it("set name", async () => {
            await mate.mint(admin.address, 0);
            await mateMessage.set(0, "도지사운드클럽");
            expect(await mateMessage.messages(0)).to.be.equal("도지사운드클럽");
        })
    })
})