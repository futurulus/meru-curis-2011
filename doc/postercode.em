function rollingVelFn(pres) {
    if(pres.velocity.lengthSquared() <
            ROLLING_FRICTION * ROLLING_FRICTION)
        return <0, 0, 0>;

    return pres.velocity - pres.velocity.normal() * ROLLING_FRICTION;
}

for(var i in balls)
{
    balls[i].coll = new motion.Collision(balls[i],
            coll.TestSpheres(balls), billiardsBounce);
    balls[i].bounds = new motion.Collision(balls[i],
            coll.TestBounds(table.position + TABLE_BOUNDS.max,
                            table.position + TABLE_BOUNDS.min),
            coll.Bounce(ELASTICITY));
    balls[i].rolling = new motion.Velocity(balls[i], rollingVelFn);
}
