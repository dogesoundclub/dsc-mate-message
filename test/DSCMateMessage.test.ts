import { expect } from "chai";
import { ethers, network, waffle } from "hardhat";
import DogeSoundClubMateArtifact from "../artifacts/contracts/DogeSoundClubMate.sol/DogeSoundClubMate.json";
import DSCMateMessageArtifact from "../artifacts/contracts/DSCMateMessage.sol/DSCMateMessage.json";
import { DogeSoundClubMate } from "../typechain/DogeSoundClubMate";
import { DSCMateMessage } from "../typechain/DSCMateMessage";
import DSCMateNameArtifact from "../artifacts/contracts/DSCMateName.sol/DSCMateName.json";
import { DSCMateName } from "../typechain/DSCMateName";

const { deployContract } = waffle;

async function mine(count = 1): Promise<void> {
    expect(count).to.be.gt(0);
    for (let i = 0; i < count; i += 1) {
        await ethers.provider.send("evm_mine", []);
    }
}

describe("DSCMateMessage", () => {
    let mate: DogeSoundClubMate;
    let mateName: DSCMateName;
    let mateMessage: DSCMateMessage;

    const provider = waffle.provider;
    const [admin, other] = provider.getWallets();

    beforeEach(async () => {
        mate = await deployContract(
            admin,
            DogeSoundClubMateArtifact,
            []
        ) as DogeSoundClubMate;
        mateName = await deployContract(
            admin,
            DSCMateNameArtifact,
            [mate.address]
        ) as DSCMateName;
        mateMessage = await deployContract(
            admin,
            DSCMateMessageArtifact,
            [mate.address, mateName.address]
        ) as DSCMateMessage;
    })

    context("new DSCMateMessage", async () => {
        it("set message", async () => {
            await mate.mint(admin.address, 0);
            await expect(mateMessage.set(0, "도지사운드클럽"))
                .to.emit(mateMessage, "Set")
                .withArgs(0, admin.address, "", "도지사운드클럽")
            expect((await mateMessage.record(0, (await mateMessage.recordCount(0)).sub(1)))[2]).to.be.equal("도지사운드클럽");
        })

        it("set message twice", async () => {
            await mate.mint(admin.address, 0);
            await expect(mateMessage.set(0, "도지사운드클럽"))
                .to.emit(mateMessage, "Set")
                .withArgs(0, admin.address, "", "도지사운드클럽")
            await mateMessage.setChangeInterval(1);
            expect((await mateMessage.record(0, (await mateMessage.recordCount(0)).sub(1)))[2]).to.be.equal("도지사운드클럽");
            await expect(mateMessage.set(0, "왈왈"))
                .to.emit(mateMessage, "Set")
                .withArgs(0, admin.address, "", "왈왈")
            expect((await mateMessage.record(0, (await mateMessage.recordCount(0)).sub(1)))[2]).to.be.equal("왈왈");
        })
    })
})