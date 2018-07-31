import *  as express from 'express';
import { draftModel } from '../models/draft.model.js';
import { UserData } from '../models/authentication.model.js';
import { passwords } from '../passwords.js';

const router = express.Router();

router.post('/startDraft', passwords.authorize, async (req, res, next) => {
    try {
        const user: UserData = (req as any).user;
        const worked = await draftModel.startDraft(user);
        if (worked !== false)
            res.json({
                message: 'Draft started',
                data: worked
            });
        else 
            res.status(400).json({
                message: 'Cannot start drart'
            });
    } catch (e) {
        next(e);
    }
});

router.post('/updateDraft', passwords.authorize, async (req, res, next) => {
    try {
        const user: UserData = (req as any).user;
        await draftModel.updateDraft(user, req.body.draftData);
        res.json({message: 'success'});
    } catch (e) {
        next(e);
    }
});

router.post('/getDraft', passwords.authorize, async (req, res, next) => {
    try {
        const user: UserData = (req as any).user;
        let draftData = await draftModel.getDraft(user);
        res.json({message: 'success', draftData: draftData});
    } catch (e) {
        next(e);
    }
});

router.post('/endDraft', passwords.authorize, async (req, res, next) => {
    try {
        const user: UserData = (req as any).user;
        const reward = await draftModel.endDraft(user, req.body.draftData);
        res.json({message: 'success', reward});
    } catch (e) {
        next(e);
    }
});

export const draftRouter = router;
