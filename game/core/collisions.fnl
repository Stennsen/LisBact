(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :core.collisions))

(local {: find : pair-eq} (require-mod! :core.utils))

(fn []
  (let [world (love.physics.newWorld 0 0 true)]
    (fn new-circle [id is-enemy x y size]
      (let [circle (love.physics.newCircleShape size)
            body (love.physics.newBody world x y :dynamic)
            fixture (love.physics.newFixture body circle)]
        (fixture:setUserData { :type :swarm :id id :is-enemy is-enemy })
        fixture))

    (fn create-collider [x y w h]
      (let [shape (love.physics.newEdgeShape x y (+ x w) (+ y h))
            body (love.physics.newBody world x y :static)
            fixture (love.physics.newFixture body shape)]
          (fixture:setUserData { :type :collider })
          fixture
        ))

    (fn destroy [fixture] (fixture:destroy))

    (fn add-map-colliders [{: min-x : min-y : max-x : max-y}]
      (let [xsize (- max-x min-x)
            ysize (- max-y min-y)]
        (create-collider (- min-x 10) (- min-y 10) (+ xsize 20) 10)
        (create-collider (- min-x 10) (- min-y 10) 10 (+ ysize 20))
        (create-collider max-x (- min-y 10) 10 (+ ysize 20))
        (create-collider (- min-x 10) max-y (+ xsize 20) 10)))

    (fn in-fixture [fixture x y] (fixture:testPoint x y))

    (fn update [dt] (world:update dt))

    (fn get-contacts [] (world:getContacts))

    {: new-circle : in-fixture : add-map-colliders : update : get-contacts : destroy }))
