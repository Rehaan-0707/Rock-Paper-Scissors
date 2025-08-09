module rehaan_addr::RockPaperScissors {
    use aptos_framework::signer;
    use std::vector;
    use aptos_framework::timestamp;
    
    const GAME_WAITING: u8 = 0;
    const GAME_COMMITTED: u8 = 1;
    const GAME_REVEALED: u8 = 2;
    const GAME_FINISHED: u8 = 3;
    
    const ROCK: u8 = 1;
    const PAPER: u8 = 2;
    const SCISSORS: u8 = 3;
    
    struct Game has store, key {
        player1: address,
        player2: address,
        player1_commit: vector<u8>,  
        player2_commit: vector<u8>,  
        player1_move: u8,           
        player2_move: u8,           
        winner: address,          
        state: u8,                  
        created_at: u64,            
    }
    
  
    public fun create_game_and_commit(
        player1: &signer, 
        player2_address: address, 
        commit_hash: vector<u8>
    ) {
        let player1_addr = signer::address_of(player1);
        let game = Game {
            player1: player1_addr,
            player2: player2_address,
            player1_commit: commit_hash,
            player2_commit: vector::empty<u8>(),
            player1_move: 0,
            player2_move: 0,
            winner: @0x0,
            state: GAME_WAITING,
            created_at: timestamp::now_seconds(),
        };
        move_to(player1, game);
    }
    
    
    public fun commit_and_reveal(
        player2: &signer, 
        game_owner: address, 
        player2_commit_hash: vector<u8>,
        player1_move: u8,
        player1_secret: vector<u8>,
        player2_move: u8
    ) acquires Game {
        let game = borrow_global_mut<Game>(game_owner);
        let player2_addr = signer::address_of(player2);
        
       
        assert!(game.player2 == player2_addr, 1);
        
        
        game.player2_commit = player2_commit_hash;
        game.player1_move = player1_move;
        game.player2_move = player2_move;
        
        
        game.winner = determine_winner(player1_move, player2_move, game.player1, game.player2);
        game.state = GAME_FINISHED;
    }
    
    
    fun determine_winner(move1: u8, move2: u8, player1: address, player2: address): address {
        if (move1 == move2) {
            @0x0  // Tie
        } else if ((move1 == ROCK && move2 == SCISSORS) ||
                   (move1 == PAPER && move2 == ROCK) ||
                   (move1 == SCISSORS && move2 == PAPER)) {
            player1  
        } else {
            player2  // Player 2 wins
        }
    }

}
