import { NameGenerator } from './nameGenerator';
import { DeckList } from './game_model/deckList';
import { GameFormat } from './game_model/gameFormat';

let ng = new NameGenerator();

export class Account {
    username: string;
    token: string;
    gameId: string | null;
    lastUsed: Date;
    deck: DeckList = new DeckList(new GameFormat());

    constructor(token: string, name: string) {
        this.token = token;
        this.username = name;
        this.gameId = null;
        this.freshen();
    }

    public freshen() {
        this.lastUsed = new Date();
    }

    public setInGame(gameId: string | null) {
        this.gameId = gameId;
    }

    public getGame() {
        return this.gameId;
    }
}
